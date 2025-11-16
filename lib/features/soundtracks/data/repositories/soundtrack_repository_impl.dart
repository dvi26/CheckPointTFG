import 'dart:convert';
import '../../../../core/api/igdb_client.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/soundtrack_repository.dart';
import '../../domain/repositories/spotify_repository.dart';

/// Implementación del repositorio de soundtracks
/// Usa IGDB solo para buscar OSTs de juegos específicos
class SoundtrackRepositoryImpl implements SoundtrackRepository {
  final IgdbClient _igdbClient;
  final SpotifyRepository _spotifyRepository;

  SoundtrackRepositoryImpl(this._igdbClient, this._spotifyRepository);

  @override
  Future<List<Soundtrack>> getPopularSoundtracks({int limit = 10}) async {
    // Lista que será el resultado final
    List<Soundtrack> result = [];
    
    try {
      // Usar solo Spotify para obtener OSTs populares
      // Spotify ordena automáticamente por popularidad + relevancia
      
      // Queries variadas para obtener diversidad de resultados
      final queries = [
        'video game soundtrack',
        'game OST',
        'videogame original soundtrack',
      ];
      
      final allSoundtracks = <Soundtrack>[];
      final seenIds = <String>{};
      
      // Buscar con cada query y combinar resultados
      for (var query in queries) {
        // Si ya tenemos suficientes, no hacer más búsquedas
        if (allSoundtracks.length >= limit) {
          break;
        }
        
        final results = await _spotifyRepository.searchGameSoundtracks(
          limit: (limit / queries.length).ceil(),
          query: query,
        );
        
        for (var soundtrack in results) {
          final notDuplicate = !seenIds.contains(soundtrack.id);
          final hasSpace = allSoundtracks.length < limit;
          
          if (notDuplicate && hasSpace) {
            seenIds.add(soundtrack.id);
            allSoundtracks.add(soundtrack);
          }
        }
      }

      // Asignar resultados si todo fue bien
      result = allSoundtracks;
      // print('✅ Cargados ${result.length} soundtracks populares (Spotify)');
      
    } catch (e) {
      // En caso de error, result ya está inicializado como lista vacía
      // print('❌ Error obteniendo soundtracks populares: $e');
    }
    
    return result;
  }

  @override
  Future<List<Soundtrack>> getSoundtracksByGameId(int gameId) async {
    // Lista que será el resultado final
    List<Soundtrack> result = [];
    
    try {
      // Obtener información del juego desde IGDB
      final query = '''
        fields name, cover.image_id, first_release_date;
        where id = $gameId;
      ''';

      final response = await _igdbClient.post('games', query);
      final List<dynamic> data = json.decode(response.body);

      // Verificar si encontramos el juego
      if (data.isNotEmpty) {
        final gameData = data.first;

        // Extraer nombre del juego
        String gameName = 'Unknown Game';
        if (gameData['name'] != null) {
          gameName = gameData['name'] as String;
        }

        // Buscar el OST del juego en Spotify
        final soundtrack = await _spotifyRepository.searchSoundtrackForGame(gameName);

        // Si encontramos el soundtrack, crear lista con información combinada
        if (soundtrack != null) {
          result = [
            Soundtrack(
              id: soundtrack.id,
              name: soundtrack.name,
              coverUrl: soundtrack.coverUrl,
              composer: soundtrack.composer,
              releaseYear: soundtrack.releaseYear,
              gameId: gameId, 
              gameName: gameName,
              popularity: soundtrack.popularity,
              totalTracks: soundtrack.totalTracks,
              spotifyUrl: soundtrack.spotifyUrl,
              previewUrl: soundtrack.previewUrl,
            ),
          ];
        }
      }
      
    } catch (e) {
      // En caso de error, result ya está inicializado como lista vacía
      // print('❌ Error obteniendo soundtracks del juego $gameId: $e');
    }
    
    return result;
  }
}
