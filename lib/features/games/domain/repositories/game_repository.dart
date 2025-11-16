import '../entities/game.dart';

/// Interfaz del repositorio de juegos
abstract class GameRepository {
  /// Obtiene juegos populares (mejor valorados)
  Future<List<Game>> getPopularGames({int limit = 10});
  
  /// Busca juegos por nombre
  Future<List<Game>> searchGames(String query, {int limit = 10});
  
  /// Obtiene detalles de un juego específico
  Future<Game?> getGameById(int id);
}
