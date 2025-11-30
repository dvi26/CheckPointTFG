import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/igdb_client.dart';
import '../../../../core/utils/platform_mapper.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/game_model.dart';

/// Implementación del repositorio de juegos usando IGDB API
class GameRepositoryImpl implements GameRepository {
  final IgdbClient _client;
  
  // Claves para SharedPreferences
  static const String _platformsCacheKey = 'igdb_platforms_data';
  static const String _platformsTimestampKey = 'igdb_platforms_timestamp';
  // Duración del caché de plataformas (30 días)
  static const Duration _cacheDuration = Duration(days: 30);

  // Diccionarios que guardan géneros y plataformas en memoria
  Map<int, String>? _genreCache;
  Map<int, String>? _platformCache;

  GameRepositoryImpl(this._client);

  /// Carga los géneros de juegos desde la API y los guarda en memoria.
  /// Solo se ejecuta la primera vez, las siguientes veces usa el cache.
  Future<void> _loadGenres() async {
    if (_genreCache == null) {
      try {
        final response = await _client.post(
          'genres',
          'fields name; limit 100;',
        );

        final List<dynamic> data = json.decode(response.body);
        
        final Map<int, String> genreMap = {};
        for (var genre in data) {
          final int id = genre['id'] as int;
          final String name = genre['name'] as String;
          genreMap[id] = name;
        }
        
        _genreCache = genreMap;
      } catch (e) {
        _genreCache = {};
      }
    }
  }

  /// Carga las plataformas con estrategia cache-first usando SharedPreferences.
  /// 
  /// 1. Intenta cargar desde SharedPreferences.
  /// 2. Si hay datos y no han expirado, usa el caché local.
  /// 3. Si no hay datos o expiraron, descarga de la API y actualiza el caché.
  Future<void> _loadPlatforms({bool forceReload = false}) async {
    // Si ya tenemos caché en memoria y no forzamos recarga, terminamos.
    if (_platformCache != null && !forceReload) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Intentar cargar desde SharedPreferences si no forzamos recarga
      if (!forceReload) {
        final cachedData = prefs.getString(_platformsCacheKey);
        final timestamp = prefs.getInt(_platformsTimestampKey);

        if (cachedData != null && timestamp != null) {
          final cachedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final now = DateTime.now();

          // Verificar si el caché es válido (menos de 30 días)
          if (now.difference(cachedDate) < _cacheDuration) {
            final Map<String, dynamic> decodedMap = json.decode(cachedData);
            _platformCache = decodedMap.map((key, value) => MapEntry(int.parse(key), value as String));
            
            // Actualizar el PlatformMapper con los datos cacheados
            PlatformMapper.updatePlatforms(_platformCache!);
            return;
          }
        }
      }

      // Si llegamos aquí, necesitamos cargar desde la API (cache expirado, inexistente o forceReload)
      
      // Obtener TODAS las plataformas disponibles en IGDB (máximo 500 según límite de IGDB)
      final response = await _client.post(
        'platforms',
        'fields id, name; limit 500;',
      );

      final List<dynamic> data = json.decode(response.body);
      
      final Map<int, String> platformMap = {};
      for (var platform in data) {
        final int id = platform['id'] as int;
        final String name = platform['name'] as String;
        platformMap[id] = name;
      }
      
      _platformCache = platformMap;

      // Guardar en SharedPreferences
      // Convertimos las keys int a String para poder serializar a JSON
      final jsonMap = platformMap.map((key, value) => MapEntry(key.toString(), value));
      await prefs.setString(_platformsCacheKey, json.encode(jsonMap));
      await prefs.setInt(_platformsTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      // Actualizar el PlatformMapper con los nuevos datos
      PlatformMapper.updatePlatforms(_platformCache!);

    } catch (e) {
      // Si falla la API y no teníamos caché, inicializamos vacío para no romper la app
      _platformCache ??= {};
      // Log error o manejar silenciosamente
      print('Error cargando plataformas: $e');
    }
  }

  /// Carga géneros y plataformas en paralelo
  Future<void> _loadCaches({bool forceReloadPlatforms = false}) async {
    await Future.wait([
      _loadGenres(),
      _loadPlatforms(forceReload: forceReloadPlatforms),
    ]);
  }

  @override
  Future<List<Game>> getPopularGames({int limit = 10}) async {
    await _loadCaches();

    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final timestamp = (sixMonthsAgo.millisecondsSinceEpoch / 1000).round();

    final query = '''
      fields name, rating, rating_count, cover.image_id, genres, platforms, 
             first_release_date, summary, storyline,
             involved_companies.company.name, involved_companies.developer, involved_companies.publisher,
             websites.type, websites.url,
             screenshots.image_id;
      where first_release_date >= $timestamp & hypes > 30 & cover != null;
      sort hypes desc;
      limit $limit;
    ''';

    final response = await _client.post('games', query);
    final List<dynamic> data = json.decode(response.body);

    final seenNames = <String>{};
    final games = <Game>[];
    
    for (var gameJson in data) {
      final game = GameModel.fromJson(gameJson).toEntity(
        genreMap: _genreCache,
        platformMap: _platformCache,
      );
      
      final nameLower = game.name.toLowerCase();
      if (!seenNames.contains(nameLower)) {
        seenNames.add(nameLower);
        games.add(game);
      }
    }

    return games;
  }

  @override
  Future<List<Game>> searchGames(String query, {int limit = 10}) async {
    await _loadCaches();

    final igdbQuery = '''
      search "$query";
      fields name, rating, rating_count, cover.image_id, genres, platforms,
             first_release_date, summary, storyline,
             involved_companies.company.name, involved_companies.developer, involved_companies.publisher,
             websites.type, websites.url,
             screenshots.image_id;
      where cover != null;
      limit $limit;
    ''';

    final response = await _client.post('games', igdbQuery);
    final List<dynamic> data = json.decode(response.body);

    return data
        .map((json) => GameModel.fromJson(json).toEntity(
              genreMap: _genreCache,
              platformMap: _platformCache,
            ))
        .toList();
  }

  @override
  Future<Game?> getGameById(int id) async {
    await _loadCaches();

    final query = '''
      fields name, rating, rating_count, cover.image_id, genres, platforms,
             first_release_date, summary, storyline,
             involved_companies.company.name, involved_companies.developer, involved_companies.publisher,
             websites.type, websites.url,
             screenshots.image_id;
      where id = $id;
    ''';

    final response = await _client.post('games', query);
    final List<dynamic> data = json.decode(response.body);

    if (data.isEmpty) {
      return null;
    }

    return GameModel.fromJson(data.first).toEntity(
      genreMap: _genreCache,
      platformMap: _platformCache,
    );
  }
}
