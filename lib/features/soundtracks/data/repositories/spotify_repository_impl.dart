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
    String query = 'video game soundtrack',
  }) async {
    // Lista que será el resultado final
    List<Soundtrack> result = [];
    
    try {
      final spotifyApi = await SpotifyClientService.getClient();
      
      // Buscar álbumes con el query especificado
      // Pedimos más del límite porque vamos a filtrar muchos resultados
      final results = await spotifyApi.search
          .get(query, types: [SearchType.album])
          .first(limit * 3);
      
      final soundtracks = <Soundtrack>[];
      
      // Palabras clave que indican compilaciones o listas
      final excludeKeywords = [
        'best of',
        'greatest hits',
        'collection',
        'playlist',
        'top',
        'ultimate',
        'essential',
        'complete',
        'compilation',
        'hits',
        'epic',
        'legendary',
        'greatest',
        'masterpieces',
        'classics',
        'anthology',
        'deluxe',
        'expanded',
        'remastered',
        'anniversary',
        'special edition',
        'various artists',
        'vol.',
        'volume',
        'part',
      ];
      
      // Procesar cada página de resultados
      for (var page in results) {
        for (var item in page.items!) {
          if (item is AlbumSimple) {
            // Obtener el nombre del álbum en minúsculas para comparación
            String albumName = '';
            if (item.name != null) {
              albumName = item.name!.toLowerCase();
            }
            
            // Filtro 1: Rechazar si contiene palabras de compilación
            final hasExcludedKeyword = excludeKeywords.any((keyword) => 
              albumName.contains(keyword)
            );
            
            // Filtro 2: Debe contener palabras que indiquen que es un OST oficial
            final isSoundtrack = albumName.contains('soundtrack') || 
                                 albumName.contains('ost') || 
                                 albumName.contains('score') ||
                                 albumName.contains('original');
            
            // Solo agregar si pasa ambos filtros
            if (!hasExcludedKeyword && isSoundtrack) {
              final model = SpotifySoundtrackModel(album: item);
              soundtracks.add(model.toEntity());
              
              // Si ya tenemos suficientes, dejar de procesar
              if (soundtracks.length >= limit) {
                break;
              }
            }
          }
        }
        
        // Si ya tenemos suficientes, dejar de procesar páginas
        if (soundtracks.length >= limit) {
          break;
        }
      }
      
      // Asignar resultados si todo fue bien
      result = soundtracks;
      // print('✅ Spotify: Encontrados ${result.length} soundtracks (filtrados)');
      
    } catch (e) {
      // En caso de error, result ya está inicializado como lista vacía
      // print('❌ Error buscando soundtracks en Spotify: $e');
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
                // print('✅ Spotify: Encontrado OST para "$gameName": ${item.name}');
                break;
              }
            }
          }
        }
      }
      
      if (result == null) {
        // print('⚠️ Spotify: No se encontró OST para "$gameName"');
      }
      
    } catch (e) {
      // En caso de error, result ya está en null
      // print('❌ Error buscando OST de "$gameName": $e');
    }
    
    return result;
  }
}
