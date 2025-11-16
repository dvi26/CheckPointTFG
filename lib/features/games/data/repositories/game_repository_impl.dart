import 'dart:convert';
import '../../../../core/api/igdb_client.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/game_model.dart';

/// Implementación del repositorio de juegos usando IGDB API
class GameRepositoryImpl implements GameRepository {
  final IgdbClient _client;

  // Diccionario que guarda los géneros en memoria para evitar múltiples llamadas
  Map<int, String>? _genreCache;

  GameRepositoryImpl(this._client);

  /// Carga los géneros de juegos desde la API y los guarda en memoria.
  /// Solo se ejecuta la primera vez, las siguientes veces usa el cache.
  Future<void> _loadGenres() async {
    // Solo cargar si aún no están en memoria
    if (_genreCache == null) {
      try {
        // Pedir lista de géneros a la API
        final response = await _client.post(
          'genres',
          'fields name; limit 100;',
        );

        // Convertir respuesta JSON a lista
        final List<dynamic> data = json.decode(response.body);
        
        // Crear diccionario: {id: nombre}
        // Ejemplo: {1: "Action", 2: "RPG", 3: "Adventure"}
        final Map<int, String> genreMap = {};
        for (var genre in data) {
          final int id = genre['id'] as int;
          final String name = genre['name'] as String;
          genreMap[id] = name;
        }
        
        _genreCache = genreMap;
      } catch (e) {
        // Si falla, crear diccionario vacío para no intentar de nuevo
        _genreCache = {};
        // print('⚠️ Error cargando géneros: $e');
      }
    }
  }

  @override
  Future<List<Game>> getPopularGames({int limit = 10}) async {
    await _loadGenres();

    // Timestamp de hace 6 meses (juegos populares ahora mismo)
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final timestamp = (sixMonthsAgo.millisecondsSinceEpoch / 1000).round();

    // Query IGDB: juegos con más hype de los últimos 6 meses
    final query = '''
      fields name, rating, cover.image_id, genres, first_release_date, summary;
      where first_release_date >= $timestamp & hypes > 30 & cover != null;
      sort hypes desc;
      limit $limit;
    ''';

    final response = await _client.post('games', query);
    final List<dynamic> data = json.decode(response.body);

    // Evitar juegos duplicados por nombre
    final seenNames = <String>{};
    final games = <Game>[];
    
    for (var gameJson in data) {
      final game = GameModel.fromJson(gameJson).toEntity(genreMap: _genreCache);
      
      // Solo agregar si no hemos visto este nombre antes
      final nameLower = game.name.toLowerCase();
      if (!seenNames.contains(nameLower)) {
        seenNames.add(nameLower);
        games.add(game);
      }
    }

    // print('✅ Cargados ${games.length} juegos populares'); 
    return games;
  }

  @override
  Future<List<Game>> searchGames(String query, {int limit = 10}) async {
    await _loadGenres();

    // Query IGDB: búsqueda por nombre
    final igdbQuery = '''
      search "$query";
      fields name, rating, cover.image_id, genres, first_release_date, summary;
      where cover != null;
      limit $limit;
    ''';

    final response = await _client.post('games', igdbQuery);
    final List<dynamic> data = json.decode(response.body);

    return data
        .map((json) => GameModel.fromJson(json).toEntity(genreMap: _genreCache))
        .toList();
  }

  @override
  Future<Game?> getGameById(int id) async {
    await _loadGenres();

    final query = '''
      fields name, rating, cover.image_id, genres, first_release_date, summary;
      where id = $id;
    ''';

    final response = await _client.post('games', query);
    final List<dynamic> data = json.decode(response.body);

    if (data.isEmpty) {
      return null;
    }

    return GameModel.fromJson(data.first).toEntity(genreMap: _genreCache);
  }
}
