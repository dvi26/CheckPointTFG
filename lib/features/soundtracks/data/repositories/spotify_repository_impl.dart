import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify/spotify.dart';
import '../../../../core/api/spotify_client.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../models/spotify_soundtrack_model.dart';

/// Implementación del repositorio de Spotify para soundtracks
class SpotifyRepositoryImpl implements SpotifyRepository {
  
  @override
  /// Busca soundtracks de videojuegos en Spotify.
  /// Ordena por popularidad y relevancia automáticamente.
  /// Filtra compilaciones, playlists y álbumes no oficiales.
  Future<List<Soundtrack>> searchGameSoundtracks({
    int limit = 20,
    int offset = 0,
    String query = 'video game soundtrack',
  }) async {
    // Lista que será el resultado final
    List<Soundtrack> result = [];
    
    try {
      final spotifyApi = await SpotifyClientService.getClient();
      
      // Construir query avanzada para encontrar más resultados relevantes
      // Buscamos el término junto con palabras clave de OST
      // Usamos comillas para buscar la frase exacta del usuario si es posible, 
      // pero a veces es mejor dejarlo abierto.
      final advancedQuery = '$query (soundtrack OR ost OR score OR game OR music)';
      final encodedQuery = Uri.encodeComponent(advancedQuery);
      
      final searchLimit = 50; // Pedimos el máximo posible por página
      
      // Obtener el token de acceso actual
      final accessToken = await spotifyApi.getCredentials();
      final token = accessToken.accessToken;

      // Hacer petición HTTP manual
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$encodedQuery&type=album&limit=$searchLimit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final jsonBody = json.decode(response.body);
      final albumsData = jsonBody['albums']['items'] as List;
      
      final soundtracks = <Soundtrack>[];
      
      // Palabras clave que indican compilaciones o contenido no oficial
      final excludeKeywords = [
        'best of',
        'greatest hits',
        'collection',
        'playlist',
        'top',
        'ultimate',
        'essential',
        'compilation',
        'hits',
        'epic',
        'legendary',
        'greatest',
        'masterpieces',
        'classics',
        'anthology',
        'various artists',
        'karaoke',
        'tribute',
        'cover',
        'remix',
        'lofi',
        'lo-fi',
        'piano version',
        'metal version',
        '8-bit',
      ];
      
      for (var itemJson in albumsData) {
        // Convertir JSON a AlbumSimple usando el modelo de la librería
        final item = AlbumSimple.fromJson(itemJson);
        
        // Obtener el nombre del álbum en minúsculas para comparación
        String albumName = '';
        if (item.name != null) {
          albumName = item.name!.toLowerCase();
        }
        
        // Rechazar si contiene palabras de compilación o covers
        final hasExcludedKeyword = excludeKeywords.any((keyword) => 
          albumName.contains(keyword)
        );
        
        // Debe contener palabras que indiquen que es un OST oficial
        // O contener "music from" que es común
        final isSoundtrack = albumName.contains('soundtrack') || 
                             albumName.contains('ost') || 
                             albumName.contains('score') ||
                             albumName.contains('original') ||
                             albumName.contains('music from') ||
                             albumName.contains('game');
        
        // Solo agregar si pasa ambos filtros
        if (!hasExcludedKeyword && isSoundtrack) {
          final model = SpotifySoundtrackModel(album: item);
          soundtracks.add(model.toEntity());
        }
      }
      
      // Asignar resultados
      result = soundtracks;
      
    } catch (e) {
      // En caso de error, result ya está inicializado como lista vacía
      // print('Error searching soundtracks: $e');
    }
    
    return result;
  }

  @override
  /// Busca el soundtrack oficial de un juego específico.
  /// Prueba con múltiples variaciones del nombre para aumentar posibilidades de éxito.
  /// Retorna el primer soundtrack que coincida, o null si no se encuentra.
  Future<Soundtrack?> searchSoundtrackForGame(String gameName) async {
    // Variable que contendrá el resultado final
    Soundtrack? result;
    
    try {
      final spotifyApi = await SpotifyClientService.getClient();
      
      // Buscar con varios términos para aumentar posibilidades
      final queries = [
        '$gameName soundtrack',
        '$gameName OST',
        '$gameName original soundtrack',
      ];
      
      // Variable para saber si ya encontramos resultado
      bool found = false;
      
      // Probar con cada query hasta encontrar un resultado
      for (var query in queries) {
        if (found) {
          break;
        }
        
        // Buscar álbumes con este query
        final results = await spotifyApi.search
            .get(query, types: [SearchType.album])
            .first(5); 
        
        // Procesar cada página de resultados
        for (var page in results) {
          if (found) {
            break;
          }
          
          for (var item in page.items!) {
            if (item is AlbumSimple) {
              // Obtener nombre del álbum en minúsculas para comparación
              String albumName = '';
              if (item.name != null) {
                albumName = item.name!.toLowerCase();
              }
              final gameNameLower = gameName.toLowerCase();
              
              // Verificar que el álbum corresponde al juego
              // Debe contener el nombre del juego O palabras clave de OST
              if (albumName.contains(gameNameLower) || 
                  albumName.contains('soundtrack') ||
                  albumName.contains('ost')) {
                
                // Crear modelo con información del juego
                final model = SpotifySoundtrackModel(
                  album: item,
                  gameName: gameName,
                );
                
                // Asignar resultado y marcar como encontrado
                result = model.toEntity();
                found = true;
                break;
              }
            }
          }
        }
      }
      
    } catch (e) {
      // En caso de error, result ya está en null
    }
    
    return result;
  }

  @override
  /// Obtiene un álbum completo de Spotify con toda la información detallada
  Future<Soundtrack?> getSoundtrackById(
    String spotifyId, {
    String? gameName,
    int? gameId,
  }) async {
    Soundtrack? result;
    
    try {
      final spotifyApi = await SpotifyClientService.getClient();
      
      // Obtener álbum completo (no AlbumSimple)
      final album = await spotifyApi.albums.get(spotifyId);
      
      // Crear modelo con información completa del álbum
      final model = SpotifySoundtrackModel(
        album: album,
        gameName: gameName,
        gameId: gameId,
      );
      
      result = model.toEntity();
      
    } catch (e) {
      // En caso de error, result ya está en null
    }
    
    return result;
  }
}
