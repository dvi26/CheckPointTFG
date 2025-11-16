import '../entities/soundtrack.dart';

/// Interface del repositorio de soundtracks
abstract class SoundtrackRepository {
  /// Obtiene soundtracks populares/destacados
  Future<List<Soundtrack>> getPopularSoundtracks({int limit = 10});
  
  /// Obtiene soundtracks de un juego específico
  Future<List<Soundtrack>> getSoundtracksByGameId(int gameId);
}
