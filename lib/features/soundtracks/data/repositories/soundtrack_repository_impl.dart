import 'dart:convert';
import '../../../../core/api/igdb_client.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/musicbrainz_repository.dart';
import '../../domain/repositories/soundtrack_repository.dart';
import '../../domain/repositories/spotify_repository.dart';

/// Implementación del repositorio de soundtracks
/// Usa MusicBrainz como fuente principal de verdad para resultados precisos de videojuegos
/// Usa Spotify como fallback y proveedor de streaming
class SoundtrackRepositoryImpl implements SoundtrackRepository {
  final IgdbClient _igdbClient;
  final SpotifyRepository _spotifyRepository;
  final MusicBrainzRepository _musicBrainzRepository;

  SoundtrackRepositoryImpl(
    this._igdbClient, 
    this._spotifyRepository,
    this._musicBrainzRepository,
  );

  @override
  Future<List<Soundtrack>> getPopularSoundtracks({int limit = 10}) async {
    List<Soundtrack> result = [];
    try {
      // Obtener juegos populares de IGDB para asegurar relevancia real
      // Simplificamos la query para evitar problemas con category
      final igdbQuery = 'fields name, cover.image_id; sort follows desc; where rating > 80; limit $limit;';
      
      final igdbResponse = await _igdbClient.post('games', igdbQuery);
      final List<dynamic> games = json.decode(igdbResponse.body);

      // Para cada juego popular, buscar su soundtrack en MusicBrainz
      for (var game in games) {
        final gameName = game['name'] as String;
        final gameId = game['id'] as int;
        
        // Construir URL de cover IGDB como fallback
        String? igdbCoverUrl;
        if (game['cover'] != null && game['cover']['image_id'] != null) {
           igdbCoverUrl = 'https://images.igdb.com/igdb/image/upload/t_cover_big/${game['cover']['image_id']}.jpg';
        }

        // Buscar OST en MB (sin comillas para permitir fuzzy search)
        // Añadimos 'soundtrack' a la query para ayudar
        final mbResults = await _musicBrainzRepository.searchGameSoundtracks(
          query: gameName, 
          limit: 1,
        );

        if (mbResults.isNotEmpty) {
          final ost = mbResults.first;
          
          // Usar cover de MB, si es null (error 404), usar el de IGDB
          final finalCoverUrl = ost.coverUrl ?? igdbCoverUrl;

          result.add(Soundtrack(
            id: ost.id,
            name: ost.name,
            coverUrl: finalCoverUrl,
            composer: ost.composer,
            releaseYear: ost.releaseYear,
            gameId: gameId,
            gameName: gameName,
            spotifyUrl: ost.spotifyUrl,
            totalTracks: ost.totalTracks,
            tracks: ost.tracks,
          ));
        } else {
        }
      }
      
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Soundtrack>> getSoundtracksByGameId(int gameId) async {
    try {
      // Obtener nombre y cover del juego desde IGDB
      final query = 'fields name, cover.image_id; where id = $gameId;';
      final response = await _igdbClient.post('games', query);
      final List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) return [];
      
      final gameData = data.first;
      final gameName = gameData['name'] as String;
      
      String? igdbCoverUrl;
      if (gameData['cover'] != null && gameData['cover']['image_id'] != null) {
         igdbCoverUrl = 'https://images.igdb.com/igdb/image/upload/t_cover_big/${gameData['cover']['image_id']}.jpg';
      }

      // Buscar en MusicBrainz por nombre de juego)
      final mbResults = await _musicBrainzRepository.searchGameSoundtracks(
        query: gameName,
        limit: 5,
      );

      if (mbResults.isNotEmpty) {
        return mbResults.map((ost) {
          // Aplicar fallback de imagen si MB no tiene
          // MB repository devuelve URL optimista que puede dar 404, 
          // idealmente deberíamos validar, pero por ahora si viene nula o falla carga en UI, 
          // la UI debería tener un placeholder. Aquí inyectamos la de IGDB si MB devolvió null explícito.
          return Soundtrack(
            id: ost.id,
            name: ost.name,
            coverUrl: ost.coverUrl ?? igdbCoverUrl,
            composer: ost.composer,
            releaseYear: ost.releaseYear,
            gameId: gameId,
            gameName: gameName,
            spotifyUrl: ost.spotifyUrl,
            totalTracks: ost.totalTracks,
            tracks: ost.tracks,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Soundtrack?> getSoundtrackById(
    String id, {
    String? gameName,
    int? gameId,
  }) async {
    try {
      // Solo soportamos IDs de MusicBrainz (UUIDs)
      final isMbid = id.length > 30 && id.contains('-'); 

      if (isMbid) {
        final mbResult = await _musicBrainzRepository.getSoundtrackById(id);
        if (mbResult != null) {
          String? previewUrl;
          
          // Intentar obtener preview de Spotify si hay enlace
          if (mbResult.spotifyUrl != null) {
             try {
               final uri = Uri.parse(mbResult.spotifyUrl!);
               // Soportar formatos: /album/ID o /artist/ID (aunque buscamos albums)
               if (uri.pathSegments.contains('album')) {
                 final spotifyId = uri.pathSegments.last;
                 final spotifyTrack = await _spotifyRepository.getSoundtrackById(spotifyId);
                 previewUrl = spotifyTrack?.previewUrl;
               }
             } catch (_) {
               // Ignorar errores de parseo o API de Spotify
             }
          }

          return Soundtrack(
            id: mbResult.id,
            name: mbResult.name,
            coverUrl: mbResult.coverUrl, // Aquí la vista manejará el error de carga si es 404
            composer: mbResult.composer,
            releaseYear: mbResult.releaseYear,
            gameId: gameId,
            gameName: gameName,
            spotifyUrl: mbResult.spotifyUrl,
            previewUrl: previewUrl,
            totalTracks: mbResult.totalTracks,
            tracks: mbResult.tracks,
            totalDurationMinutes: mbResult.totalDurationMinutes,
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Soundtrack>> searchSoundtracks(String query, {int limit = 20, int offset = 0}) async {
    try {
      // Búsqueda Directa Optimizada en MusicBrainz
      // Ya no usamos IGDB como paso previo para acelerar la respuesta.
      // Confiamos en el filtro inteligente (Tag Check + VGMdb Link) de MusicBrainzRepository.
      
      return await _musicBrainzRepository.searchGameSoundtracks(
        query: query,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return [];
    }
  }
}
