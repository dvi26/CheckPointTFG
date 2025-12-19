import '../../../../core/api/musicbrainz_client.dart';
import '../../domain/entities/soundtrack.dart';
import '../../domain/repositories/musicbrainz_repository.dart';
import '../models/musicbrainz_soundtrack_model.dart';

class MusicBrainzRepositoryImpl implements MusicBrainzRepository {
  final MusicBrainzClient _client;

  MusicBrainzRepositoryImpl(this._client);

  @override
  Future<List<Soundtrack>> searchGameSoundtracks({
    int limit = 20,
    int offset = 0,
    String query = '',
  }) async {
    try {
      // Buscamos cualquier cosa que parezca un soundtrack con ese nombre
      String mbQuery;
      if (query.isEmpty) {
        mbQuery = 'tag:"video game soundtrack"'; 
      } else {
        // Query más relajada para capturar candidatos, luego filtraremos por VGMdb
        mbQuery = '($query) AND (secondarytype:Soundtrack OR release:"Soundtrack" OR release:"OST" OR tag:"video game soundtrack")';
      }
      
      final response = await _client.get('release', params: {
        'query': mbQuery,
        'limit': '10', 
        'offset': offset.toString(),
      });

      if (response == null || response['releases'] == null) {
        return [];
      }

      final candidates = response['releases'] as List;
      final validatedSoundtracks = <Soundtrack>[];

      // Optimizamos velocidad: Si tiene tag, aceptamos directo. Si no, verificamos enlace VGMdb.
      
      final verificationFutures = candidates.map((candidate) async {
        try {
          // Tiene tag explícito -> Aceptado inmediatamente
          // No necesitamos llamada extra de detalle, usamos la info que ya tenemos
          if (_hasGameTag(candidate)) {
            return _mapReleaseToSoundtrack(candidate);
          }

          // No tiene tag -> Verificamos enlace VGMdb (Slow Path)
          // Solo hacemos la llamada extra si es estrictamente necesario
          final id = candidate['id'] as String;
          final detail = await _client.get('release/$id', params: {
            'inc': 'url-rels artist-credits',
          });

          if (detail != null && _hasVgmdbLink(detail)) {
            return _mapReleaseToSoundtrack(detail, isDetail: true);
          }
        } catch (_) {
          // Si falla, ignorar
        }
        return null;
      });

      final results = await Future.wait(verificationFutures);
      
      for (var ost in results) {
        if (ost != null) validatedSoundtracks.add(ost);
      }

      return validatedSoundtracks.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  bool _hasVgmdbLink(Map<String, dynamic> detail) {
    if (detail['relations'] != null) {
      final relations = detail['relations'] as List;
      for (var rel in relations) {
        if (rel['url'] != null && 
            rel['url']['resource'].toString().contains('vgmdb.net')) {
          return true; 
        }
      }
    }
    return false;
  }

  bool _hasGameTag(Map<String, dynamic> data) {
    if (data['tags'] != null) {
      final tags = data['tags'] as List;
      return tags.any((t) => 
        t['name'] == 'video game soundtrack' || 
        t['name'] == 'video game music' ||
        t['name'] == 'game soundtrack'
      );
    }
    return false;
  }

  @override
  Future<Soundtrack?> getSoundtrackById(String mbid) async {
    try {
      // Obtener detalles del release incluyendo relaciones (url-rels) para buscar links a Spotify
      final response = await _client.get('release/$mbid', params: {
        'inc': 'artist-credits url-rels recordings',
      });

      if (response == null) {
        return null;
      }

      return _mapReleaseToSoundtrack(response, isDetail: true);
    } catch (e) {
      return null;
    }
  }

  Soundtrack _mapReleaseToSoundtrack(Map<String, dynamic> release, {bool isDetail = false}) {
    final model = MusicBrainzSoundtrackModel.fromJson(release);
    return model.toEntity();
  }
}
