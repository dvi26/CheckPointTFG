import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de credenciales IGDB
/// 
/// Las credenciales se cargan desde el archivo .env para mayor seguridad.
class IgdbConfig {
  /// Client ID de IGDB (Twitch Developer Console)
  static String get clientId {
    final value = dotenv.env['IGDB_CLIENT_ID'];
    if (value == null || value.isEmpty) {
      throw Exception(
        'IGDB_CLIENT_ID no encontrado en .env. '
        'Asegúrate de crear el archivo .env desde .env.example',
      );
    }
    return value;
  }

  /// Client Secret de IGDB (Twitch Developer Console)
  static String get clientSecret {
    final value = dotenv.env['IGDB_CLIENT_SECRET'];
    if (value == null || value.isEmpty) {
      throw Exception(
        'IGDB_CLIENT_SECRET no encontrado en .env. '
        'Asegúrate de crear el archivo .env desde .env.example',
      );
    }
    return value;
  }
  
  // Endpoints públicos
  static const String twitchTokenUrl = 'https://id.twitch.tv/oauth2/token';
  static const String igdbBaseUrl = 'https://api.igdb.com/v4';
}
