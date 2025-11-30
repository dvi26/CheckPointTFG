import 'package:flutter/foundation.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/soundtrack_repository.dart';

/// Controller para gestionar el estado de soundtracks
class SoundtrackController extends ChangeNotifier {
  // Capa intermedia Controller → Repository → API Client
  final SoundtrackRepository _repository;

  SoundtrackController(this._repository);

  List<Soundtrack> _popularSoundtracks = [];
  Soundtrack? _selectedSoundtrack;
  bool _isLoading = false;
  String _error = '';

  /// Lista de soundtracks populares cargados.
  List<Soundtrack> get popularSoundtracks {
    return _popularSoundtracks;
  }

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
