import 'package:spotify/spotify.dart';
import 'spotify_config.dart';

/// Cliente singleton para interactuar con Spotify API
/// Maneja autenticación automática usando Client Credentials Flow
class SpotifyClientService {
  static SpotifyApi? _spotifyApi;
  
  /// Obtiene la instancia de SpotifyApi (singleton)
  /// Autentica automáticamente si es necesario
  static Future<SpotifyApi> getClient() async {
    if (_spotifyApi != null) {
      return _spotifyApi!;
    }

    // Crear credenciales
    final credentials = SpotifyApiCredentials(
      SpotifyConfig.clientId,
      SpotifyConfig.clientSecret,
    );

    // Crear cliente con autenticación automática
    _spotifyApi = SpotifyApi(credentials);
    
    // print('✅ Spotify: Cliente autenticado correctamente'); // Debug
    return _spotifyApi!;
  }

  /// Reinicia el cliente (útil si cambian las credenciales)
  static void reset() {
    _spotifyApi = null;
  }
}
