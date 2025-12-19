import '../../../../core/api/musicbrainz_config.dart';
import '../../domain/entities/soundtrack.dart';

/// Modelo para convertir la respuesta JSON de MusicBrainz a la entidad Soundtrack
class MusicBrainzSoundtrackModel {
  final Map<String, dynamic> json;

  MusicBrainzSoundtrackModel(this.json);

  factory MusicBrainzSoundtrackModel.fromJson(Map<String, dynamic> json) =>
      MusicBrainzSoundtrackModel(json);

  Soundtrack toEntity() {
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? 'Unknown';

    int? year;
    if (json['date'] != null && (json['date'] as String).isNotEmpty) {
      year = int.tryParse((json['date'] as String).split('-')[0]);
    }

    String? composer;
    if (json['artist-credit'] != null) {
      try {
        final credits = json['artist-credit'] as List;
        if (credits.isNotEmpty) {
          composer = credits.map((c) => c['name']).join(' & ');
        }
      } catch (_) {}
    }

    String? coverUrl;
    if (json['cover-art-archive'] != null &&
        json['cover-art-archive']['front'] == true) {
      coverUrl = '${MusicBrainzConfig.coverArtBaseUrl}/release/$id/front-500';
    }

    String? spotifyUrl;
    if (json['relations'] != null) {
      try {
        final relations = json['relations'] as List;
        for (var rel in relations) {
          if (rel['url'] != null &&
              rel['url']['resource'].toString().contains('spotify.com')) {
            spotifyUrl = rel['url']['resource'];
            break;
          }
        }
      } catch (_) {}
    }

    final tracks = <Track>[];
    int? totalDurationMinutes;
    if (json['media'] != null) {
      try {
        int totalMs = 0;
        var trackCounter = 1;
        for (var media in json['media'] as List) {
          final trackList = media['tracks'] as List? ?? [];
          for (var t in trackList) {
            final duration = t['length'] as int? ?? 0;
            tracks.add(Track(
              name: t['title'] ?? 'Unknown Track',
              durationMs: duration,
              trackNumber: trackCounter++,
              previewUrl: null,
            ));
            totalMs += duration;
          }
        }
        if (totalMs > 0) totalDurationMinutes = totalMs ~/ 60000;
      } catch (_) {}
    }

    int? totalTracks;
    if (json['track-count'] != null) {
      totalTracks = json['track-count'] as int?;
    }

    return Soundtrack(
      id: id,
      name: title,
      coverUrl: coverUrl,
      composer: composer,
      releaseYear: year,
      totalTracks: totalTracks,
      spotifyUrl: spotifyUrl,
      tracks: tracks,
      totalDurationMinutes: totalDurationMinutes,
    );
  }
}
