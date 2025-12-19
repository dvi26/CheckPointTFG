import '../../../../core/api/spotify_client.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../models/spotify_soundtrack_model.dart';

/// Implementación del repositorio de Spotify para soundtracks
class SpotifyRepositoryImpl implements SpotifyRepository {
  
  @override
  /// Busca soundtracks de videojuegos en Spotify.
  /// Mantener como fallback vacío por compatibilidad de la interfaz.
  Future<List<Soundtrack>> searchGameSoundtracks({
    int limit = 20,
    int offset = 0,
    String query = 'video game soundtrack',
  }) async {
    return [];
  }

  @override
  /// Busca el soundtrack oficial de un juego específico.
  /// Mantener como fallback por compatibilidad de la interfaz.
  Future<Soundtrack?> searchSoundtrackForGame(String gameName) async {
    return null;
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
