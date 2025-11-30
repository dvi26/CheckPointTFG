import '../entities/soundtrack.dart';

/// Interfaz del repositorio de Spotify para soundtracks
abstract class SpotifyRepository {
  /// Busca soundtracks de videojuegos en Spotify.
  /// Ordena por popularidad y relevancia automáticamente.
  /// Filtra compilaciones, playlists y álbumes no oficiales.
  Future<List<Soundtrack>> searchGameSoundtracks({
    int limit = 20,
    String query = 'video game soundtrack',
  });

  /// Busca el soundtrack oficial de un juego específico.
  /// Prueba con múltiples variaciones del nombre para aumentar posibilidades de éxito.
  /// Retorna el primer soundtrack que coincida, o null si no se encuentra.
  Future<Soundtrack?> searchSoundtrackForGame(String gameName);

  /// Obtiene los detalles completos de un soundtrack por su ID de Spotify.
  /// Incluye toda la información: tracks, label, duración total, etc.
  /// Retorna null si no se encuentra el álbum.
  Future<Soundtrack?> getSoundtrackById(String spotifyId, {String? gameName, int? gameId});
}
