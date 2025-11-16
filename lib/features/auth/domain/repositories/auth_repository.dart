import '../entities/user.dart';

/// Interfaz del repositorio de autenticación
abstract class AuthRepository {
  /// Usuario actualmente autenticado.
  /// null si no hay sesión activa.
  AuthUser? get currentUser;

  /// Stream que emite eventos cuando cambia el estado de autenticación.
  /// Emite el usuario cuando inicia sesión, null cuando cierra sesión.
  Stream<AuthUser?> get authStateChanges;

  /// Inicia sesión con email y contraseña.
  /// 
  /// Retorna el usuario autenticado si todo va bien.
  /// Lanza excepción si hay error 
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con email y contraseña.
  /// 
  /// Retorna el usuario creado si todo va bien.
  /// Lanza excepción si hay error 
  Future<AuthUser> signUp({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual.
  Future<void> signOut();
}
