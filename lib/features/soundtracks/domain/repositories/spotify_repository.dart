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
}
