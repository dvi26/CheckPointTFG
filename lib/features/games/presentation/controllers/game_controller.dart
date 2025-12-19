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
  Game? _selectedGame;
  bool _isLoading = false;
  String _error = '';

  // Paginación y control de búsqueda
  int _currentSearchRequestId = 0;
  int _searchOffset = 0;
  bool _hasMoreResults = true;
  bool _isLoadingMore = false;
  String _lastQuery = '';

  /// Lista de juegos populares cargados.
  List<Game> get popularGames {
    return _popularGames;
  }

  /// Resultados de la búsqueda de juegos.
  List<Game> get searchResults {
    return _searchResults;
  }

  /// Juego seleccionado para mostrar detalles.
  Game? get selectedGame {
    return _selectedGame;
  }

  /// Indica si hay una operación en progreso.
  bool get isLoading {
    return _isLoading;
  }

  /// Indica si hay más resultados disponibles para cargar.
  bool get hasSearchResults {
    return _searchResults.isNotEmpty;
  }

  /// Indica si se están cargando más resultados.
  bool get isLoadingMore{
    return _isLoadingMore;
  }

  /// Mensaje de error actual, o String vacío si no hay error.
  String get error {
    return _error;
  }

  /// Carga juegos populares
  Future<void> loadPopularGames() async {
    // Si ya hay datos cargados, evitamos volver a llamar a la API
    // para ahorrar recursos y mejorar la experiencia de usuario.
    if (_popularGames.isNotEmpty) return;

    _setLoading(true);
    _error = '';

    try {
      // Usamos el límite por defecto del repositorio
      _popularGames = await _repository.getPopularGames();
    } catch (e) {
      _error = 'Error cargando juegos: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Busca juegos por nombre (primera página)
  Future<void> searchGames(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _lastQuery = '';
      notifyListeners();
      return;
    }

    // Reiniciar estado de paginación
    _searchOffset = 0;
    _hasMoreResults = true;
    _lastQuery = query;

    // Incrementamos el ID para invalidar peticiones anteriores
    _currentSearchRequestId++;
    final int requestId = _currentSearchRequestId;

    _setLoading(true);
    _error = '';

    try {
      final results = await _repository.searchGames(query, offset: 0);
      
      // Si esta no es la última petición lanzada, ignoramos el resultado
      if (requestId != _currentSearchRequestId) {
        return;
      }
      
      _searchResults = results;
      
      // Si recibimos menos del límite (20), no hay más resultados
      if (results.length < 20) {
        _hasMoreResults = false;
      }
    } catch (e) {
      if (requestId == _currentSearchRequestId) {
        _error = 'Error buscando juegos: $e';
      }
    } finally {
      if (requestId == _currentSearchRequestId) {
        _setLoading(false);
      }
    }
  }

  /// Carga la siguiente página de resultados
  Future<void> loadMoreSearchResults() async {
    if (_isLoadingMore || !_hasMoreResults || _lastQuery.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextOffset = _searchOffset + 20;
      final newResults = await _repository.searchGames(
        _lastQuery, 
        offset: nextOffset,
      );

      if (newResults.isEmpty) {
        _hasMoreResults = false;
      } else {
        _searchResults.addAll(newResults);
        _searchOffset = nextOffset;
        
        if (newResults.length < 20) {
          _hasMoreResults = false;
        }
      }
    } catch (e) {
      // Si falla la paginación, solo mostramos en consola o un snackbar en UI, 
      // pero no borramos los resultados existentes.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Carga los detalles completos de un juego por su ID
  Future<void> loadGameDetails(int gameId) async {
    _setLoading(true);
    _error = '';
    _selectedGame = null;

    try {
      _selectedGame = await _repository.getGameById(gameId);
    } catch (e) {
      _error = 'Error cargando detalles del juego: $e';
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
