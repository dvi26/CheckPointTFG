import 'package:flutter/foundation.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/soundtrack_repository.dart';

/// Controller para gestionar el estado de soundtracks
class SoundtrackController extends ChangeNotifier {
  // Capa intermedia Controller → Repository → API Client
  final SoundtrackRepository _repository;

  SoundtrackController(this._repository);

  List<Soundtrack> _popularSoundtracks = [];
  bool _isLoading = false;
  String _error = '';

  /// Lista de soundtracks populares cargados.
  List<Soundtrack> get popularSoundtracks {
    return _popularSoundtracks;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
