import 'package:flutter/foundation.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';

/// Controller para gestionar el estado de juegos
class GameController extends ChangeNotifier {
  // Capa intermedia Controller → Repository → API Client
  final GameRepository _repository;

  GameController(this._repository);

  List<Game> _popularGames = [];
  List<Game> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  /// Lista de juegos populares cargados.
  List<Game> get popularGames {
    return _popularGames;
  }

  /// Resultados de la búsqueda de juegos.
  List<Game> get searchResults {
    return _searchResults;
  }

  /// Indica si hay una operación en progreso.
  bool get isLoading {
    return _isLoading;
  }

  /// Mensaje de error actual, o String vacío si no hay error.
  String get error {
    return _error;
  }

  /// Carga juegos populares
  Future<void> loadPopularGames() async {
    _setLoading(true);
    _error = '';

    try {
      _popularGames = await _repository.getPopularGames(limit: 20);
      // print('✅ Cargados ${_popularGames.length} juegos populares'); 
    } catch (e) {
      _error = 'Error cargando juegos: $e';
      // print('❌ $_error'); 
    } finally {
      _setLoading(false);
    }
  }

  /// Busca juegos por nombre
  Future<void> searchGames(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = '';

    try {
      _searchResults = await _repository.searchGames(query, limit: 20);
      // print('✅ Encontrados ${_searchResults.length} juegos para "$query"'); 
    } catch (e) {
      _error = 'Error buscando juegos: $e';
      // print('❌ $_error');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpia los resultados de búsqueda
  void clearSearch() {
    _searchResults = [];
    _error = '';
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
