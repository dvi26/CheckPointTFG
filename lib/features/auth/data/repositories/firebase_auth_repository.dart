import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación usando Firebase Auth
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  @override
  AuthUser? get currentUser {
    AuthUser? result;
    
    final firebaseUser = _firebaseAuth.currentUser;
    
    if (firebaseUser != null) {
      result = _userFromFirebase(firebaseUser);
    }
    
    return result;
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        return _userFromFirebase(firebaseUser);
      }
      return null;
    });
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    AuthUser result;
    
    // Llamar a Firebase para iniciar sesión
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Verificar que obtuvimos el usuario
    if (credential.user == null) {
      throw Exception('Error al iniciar sesión: usuario no encontrado');
    }

    // Convertir a nuestra entidad
    result = _userFromFirebase(credential.user!);
    
    return result;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    AuthUser result;
    
    // Llamar a Firebase para crear cuenta
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Verificar que obtuvimos el usuario
    if (credential.user == null) {
      throw Exception('Error al crear cuenta: usuario no creado');
    }

    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user!.updateDisplayName(displayName.trim());
      // Recargar el usuario para que los cambios se reflejen
      await credential.user!.reload();
    }

    // Convertir a nuestra entidad (después de actualizar displayName)
    result = _userFromFirebase(credential.user!);
    
    return result;
  }

  @override
  Future<void> signOut() async {
    // Cerrar sesión de Google Sign-In (limpia datos locales)
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    
    // Cerrar sesión de Firebase
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    // Obtener el usuario actual de Firebase
    final currentUser = _firebaseAuth.currentUser;
    
    // Verificar que hay un usuario autenticado
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado para actualizar el nombre');
    }
    
    // Actualizar el displayName en Firebase
    await currentUser.updateDisplayName(displayName);
    
    // Recargar el usuario para que los cambios se reflejen
    await currentUser.reload();
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    AuthUser result;
    
    // Iniciar flujo de Google Sign In
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    // Usuario canceló el login
    if (googleUser == null) {
      throw Exception('Inicio de sesión cancelado');
    }
    
    // Obtener credenciales de autenticación
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Crear credencial de Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Autenticar con Firebase
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    
    // Verificar que obtuvimos el usuario
    if (userCredential.user == null) {
      throw Exception('Error al autenticar con Google');
    }
    
    // Convertir a nuestra entidad
    result = _userFromFirebase(userCredential.user!);
    
    return result;
  }

  AuthUser _userFromFirebase(User firebaseUser) {
    return AuthUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }
}
