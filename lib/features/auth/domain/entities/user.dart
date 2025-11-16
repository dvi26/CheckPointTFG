/// Entidad de un usuario autenticado.
/// 
/// Representa la información del usuario que se muestra en la UI.
/// Datos procesados y listos para usar (no depende de Firebase).
class AuthUser {
  /// ID único del usuario (uid de Firebase).
  final String id;
  
  /// Email del usuario.
  /// null si el usuario no tiene email
  final String? email;
  
  /// Nombre para mostrar del usuario.
  /// null si el usuario no ha configurado un nombre.
  final String? displayName;
  
  /// URL de la foto de perfil del usuario.
  /// null si el usuario no tiene foto configurada.
  final String? photoUrl;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}
