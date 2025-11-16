import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Controlador de autenticación.
/// Usa AuthRepository para la lógica de negocio.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String _error = '';

  AuthController(this._authRepository);

  /// Indica si hay una operación en progreso (login/registro).
  bool get isLoading {
    return _isLoading;
  }

  /// Mensaje de error actual, o String vacío si no hay error.
  String get error {
    return _error;
  }

  /// Usuario actualmente autenticado, o null si no hay sesión.
  AuthUser? get currentUser {
    return _authRepository.currentUser;
  }

  /// Indica si hay un usuario autenticado.
  bool get isSignedIn {
    return currentUser != null;
  }

  Future<void> signIn(String email, String password) async {
    // Limpiar error anterior
    _error = '';
    _setLoading(true);
    
    try {
      await _authRepository.signIn(email: email, password: password);
      // Asegurar que no hay error después de éxito
      _error = ''; 
    } on FirebaseAuthException catch (e) {
      _error = _authErrorController(e);
    } catch (_) {
      _error = 'Error inesperado. Inténtalo de nuevo.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    _error = ''; 
    _setLoading(true);
    
    try {
      await _authRepository.signUp(email: email, password: password);
      // TODO: Actualizar displayName cuando AuthUser tenga método para eso
      // Por ahora Firebase actualiza automáticamente al crear usuario
      _error = ''; 
    } on FirebaseAuthException catch (e) {
      _error = _authErrorController(e);
    } catch (_) {
      _error = 'Error inesperado. Inténtalo de nuevo.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _error = '';
    
    try {
      await _authRepository.signOut();
    } catch (e) {
      _error = 'No se pudo cerrar sesión. Intenta de nuevo.';
    } finally {
      _setLoading(false);
    }
  }

  /// Limpia el error actual
  void clearError() {
    if (_error.isNotEmpty) {
      _error = '';
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _authErrorController(FirebaseAuthException e) {
  String message;
  switch (e.code) {
    case 'invalid-email':
      message = 'Email no válido.';
      break;
    case 'user-disabled':
      message = 'Usuario deshabilitado.';
      break;
    case 'user-not-found':
      message = 'Usuario no encontrado.';
        break;
    case 'wrong-password':
      message = 'Email o contraseña incorrectos.';
      break;
    case 'weak-password':
      message = 'Contraseña demasiado débil.';
      break;
    case 'email-already-in-use':
      message = 'Este email ya está registrado.';
      break;
    case 'operation-not-allowed':
      message = 'Operación no permitida en el proyecto.';
      break;
    case 'too-many-requests':
      message = 'Demasiados intentos. Prueba más tarde.';
      break;
    default:
      message = 'Error: ${e.code}.';
  }
  return message;
}

/// Emite eventos cada vez que cambia el estado de autenticación.
  /// 
  /// Emite:
  /// - AuthUser cuando hay sesión activa (login exitoso)
  /// - null cuando no hay sesión (logout o sin autenticar)
  /// 
  /// Útil para escuchar cambios en tiempo real (ej: logout en otro dispositivo).
  Stream<AuthUser?> authStateChanges() {
    return _authRepository.authStateChanges;
  }
  
}