import 'package:flutter/foundation.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/soundtrack_repository.dart';

/// Controller para gestionar el estado de soundtracks
class SoundtrackController extends ChangeNotifier {
  // Capa intermedia Controller → Repository → API Client
  final SoundtrackRepository _repository;

  SoundtrackController(this._repository);

  List<Soundtrack> _popularSoundtracks = [];
  List<Soundtrack> _searchResults = [];
  Soundtrack? _selectedSoundtrack;
  bool _isLoading = false;
  String _error = '';

  // Paginación y control de búsqueda
  int _currentSearchRequestId = 0;
  int _searchOffset = 0;
  bool _hasMoreResults = true;
  bool _isLoadingMore = false;
  String _lastQuery = '';

  /// Lista de soundtracks populares cargados.
  List<Soundtrack> get popularSoundtracks {
    return _popularSoundtracks;
  }

  /// Resultados de la búsqueda.
  List<Soundtrack> get searchResults {
    return _searchResults;
  }

  /// Indica si hay más resultados disponibles para cargar.
  bool get hasMoreResults => _hasMoreResults;

  /// Indica si se están cargando más resultados (paginación).
  bool get isLoadingMore => _isLoadingMore;

  /// Soundtrack seleccionado para mostrar detalles.
  Soundtrack? get selectedSoundtrack {
    return _selectedSoundtrack;
  }

  /// Indica si hay una operación en progreso.
  bool get isLoading {
    return _isLoading;
  }

  /// Mensaje de error actual, o String vacío si no hay error.
  String get error {
    return _error;
  }

  /// Carga soundtracks populares
  Future<void> loadPopularSoundtracks() async {
    // Si ya hay datos cargados, evitamos volver a llamar a la API
    // para ahorrar recursos y mejorar la experiencia de usuario.
    if (_popularSoundtracks.isNotEmpty) return;

    _setLoading(true);
    _error = '';

    try {
      _popularSoundtracks = await _repository.getPopularSoundtracks(limit: 20);
      // print('✅ Cargados ${_popularSoundtracks.length} soundtracks populares');
    } catch (e) {
      _error = 'Error cargando soundtracks: $e';
      // print('❌ $_error'); 
    } finally {
      _setLoading(false);
    }
  }

  /// Busca soundtracks por nombre (primera página)
  Future<void> searchSoundtracks(String query) async {
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
      final results = await _repository.searchSoundtracks(query, offset: 0);
      
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
        _error = 'Error buscando soundtracks: $e';
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
      // Usamos bloques de 50 para la API, pero el Controller usa offset de 50 en 50 
      // porque así lo implementamos en el Repositorio (limit 50 en llamada raw).
      // El Repositorio acepta 'offset' y lo pasa directo a Spotify.
      // Spotify 'limit' es max 50.
      // Así que incrementamos offset en 50.
      final nextOffset = _searchOffset + 50;
      final newResults = await _repository.searchSoundtracks(
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
      // Error silencioso en paginación
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Limpia los resultados de búsqueda
  void clearSearch() {
    _searchResults = [];
    _error = '';
    notifyListeners();
  }

  /// Carga los detalles completos de un soundtrack por su ID de Spotify
  Future<void> loadSoundtrackDetails(
    String spotifyId, {
    String? gameName,
    int? gameId,
  }) async {
    _setLoading(true);
    _error = '';
    _selectedSoundtrack = null;

    try {
      _selectedSoundtrack = await _repository.getSoundtrackById(
        spotifyId,
        gameName: gameName,
        gameId: gameId,
      );
      // print('✅ Cargado soundtrack: ${_selectedSoundtrack?.name}');
    } catch (e) {
      _error = 'Error cargando detalles del soundtrack: $e';
      // print('❌ $_error');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
