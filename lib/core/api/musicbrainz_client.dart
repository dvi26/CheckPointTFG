import 'dart:convert';
import 'package:http/http.dart' as http;
import 'musicbrainz_config.dart';

/// Cliente HTTP para interactuar con la API de MusicBrainz
/// Maneja rate limiting y User-Agent
class MusicBrainzClient {
  static final MusicBrainzClient _instance = MusicBrainzClient._internal();
  
  factory MusicBrainzClient() {
    return _instance;
  }
  
  MusicBrainzClient._internal();
  
  // Rate limiter
  DateTime? _lastRequestTime;
  
  /// Realiza una petición GET a MusicBrainz
  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    await _enforceRateLimit();
    
    final uri = Uri.parse('${MusicBrainzConfig.baseUrl}/$endpoint').replace(
      queryParameters: {
        ...?params,
        'fmt': 'json', 
      },
    );
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': MusicBrainzConfig.userAgent,
          'Accept': 'application/json',
        },
      );
      
      _lastRequestTime = DateTime.now();
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 503) {
        // Service Unavailable - probablemente rate limit
        await Future.delayed(const Duration(seconds: 1));
        return get(endpoint, params: params); 
      } else {
        throw Exception('MusicBrainz error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling MusicBrainz: $e');
    }
  }
  
  /// Espera lo necesario para respetar el rate limit
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastRequestTime!);
      
      if (difference.inMilliseconds < 1100) {
        await Future.delayed(Duration(milliseconds: 1100 - difference.inMilliseconds));
      }
    }
  }
}
