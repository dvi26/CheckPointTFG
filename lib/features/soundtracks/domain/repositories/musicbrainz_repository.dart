import '../entities/soundtrack.dart';

abstract class MusicBrainzRepository {
  /// Busca soundtracks de videojuegos en MusicBrainz.
  Future<List<Soundtrack>> searchGameSoundtracks({
    int limit = 20,
    int offset = 0,
    String query = '',
  });

  /// Obtiene detalles de un soundtrack por su ID de MusicBrainz (MBID).
  Future<Soundtrack?> getSoundtrackById(String mbid);
}
