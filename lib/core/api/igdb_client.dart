import 'dart:convert';
import 'package:http/http.dart' as http;
import 'igdb_config.dart';

/// Cliente HTTP para interactuar con la API de IGDB
class IgdbClient {
  // Token de acceso obtenido de Twitch OAuth
  String? _accessToken;
  
  // Fecha y hora cuando el token expira 
  DateTime? _tokenExpiresAt;

  /// Autentica con Twitch y obtiene un access token para IGDB
  /// 
  /// Este método hace una petición POST a Twitch OAuth con nuestras credenciales.
  /// Si todo va bien, guardamos el token y calculamos cuándo expira.
  Future<void> _authenticate() async {
    try {
      // Hacer petición POST a Twitch OAuth
      final response = await http.post(
        Uri.parse(IgdbConfig.twitchTokenUrl),
        body: {
          'client_id': IgdbConfig.clientId,
          'client_secret': IgdbConfig.clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _accessToken = data['access_token'];
        
        final expiresIn = data['expires_in'] as int;
        final now = DateTime.now();
        _tokenExpiresAt = now.add(Duration(seconds: expiresIn));
        
        // Debug: Mostrar cuántos días es válido el token
        // final days = expiresIn ~/ 86400;
        // print('✅ IGDB: Autenticación exitosa. Token válido por $days días');
      } else {
        throw Exception('Error autenticando con Twitch: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error autenticando con IGDB: $e');
    }
  }

  /// Verifica si el token está activo, si no, autentica de nuevo
  /// 
  /// Este método se llama antes de cada petición a IGDB.
  /// Verifica 3 cosas:
  /// 1. ¿Tenemos un token?
  /// 2. ¿Tenemos fecha de expiración? 
  /// 3. ¿El token sigue vigente? 
  Future<void> _ensureAuthenticated() async {
    // Verificar si tenemos un token guardado
    bool hasToken = false;
    if (_accessToken != null) {
      hasToken = true;
    }
    
    // Verificar si tenemos fecha de expiración guardada
    bool hasExpirationDate = false;
    if (_tokenExpiresAt != null) {
      hasExpirationDate = true;
    }
    
    // Verificar si el token ya expiró
    bool isExpired = false;
    if (_tokenExpiresAt != null) {
      final now = DateTime.now();
      isExpired = now.isAfter(_tokenExpiresAt!);
    }
    
    // Si falta token, falta fecha, o ya expiró -> autenticar de nuevo
    if (!hasToken || !hasExpirationDate || isExpired) {
      await _authenticate();
    }
  }

  /// Realiza una petición POST a un endpoint de IGDB
  ///
  /// Este es el método público que usa el Repository.
  /// 
  /// [endpoint] es el recurso de IGDB
  /// [body] es la query en sintaxis Apicalypse de IGDB
  Future<http.Response> post(String endpoint, String body) async {
    // Asegurar que tenemos un token válido
    await _ensureAuthenticated();

    final baseUrl = IgdbConfig.igdbBaseUrl;
    final url = '$baseUrl/$endpoint';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Client-ID': IgdbConfig.clientId,
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'text/plain',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        final statusCode = response.statusCode;
        final responseBody = response.body;
        throw Exception('IGDB error: $statusCode - $responseBody');
      }
    } catch (e) {
      throw Exception('Error llamando a IGDB/$endpoint: $e');
    }
  }
}
