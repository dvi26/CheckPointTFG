import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de Spotify API
/// 
/// Las credenciales se cargan desde el archivo .env para mayor seguridad.

class SpotifyConfig {
  /// Client ID de Spotify Developer Dashboard
  static String get clientId {
    final value = dotenv.env['SPOTIFY_CLIENT_ID'];
    if (value == null || value.isEmpty) {
      throw Exception(
        'SPOTIFY_CLIENT_ID no encontrado en .env. '
        'Asegúrate de crear el archivo .env desde .env.example',
      );
    }
    return value;
  }

  /// Client Secret de Spotify Developer Dashboard
  static String get clientSecret {
    final value = dotenv.env['SPOTIFY_CLIENT_SECRET'];
    if (value == null || value.isEmpty) {
      throw Exception(
        'SPOTIFY_CLIENT_SECRET no encontrado en .env. '
        'Asegúrate de crear el archivo .env desde .env.example',
      );
    }
    return value;
  }
  
  // Endpoints públicos 
  static const String baseUrl = 'https://api.spotify.com/v1';
  static const String authUrl = 'https://accounts.spotify.com/api/token';
}
