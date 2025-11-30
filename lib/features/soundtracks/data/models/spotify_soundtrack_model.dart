import 'package:spotify/spotify.dart' as spotify;
import '../../domain/entities/soundtrack.dart';

/// Modelo para convertir datos de Spotify a nuestra entidad Soundtrack
class SpotifySoundtrackModel {
  final dynamic album;
  final String? gameName;
  final int? gameId;
  final String? youtubeUrl;

  SpotifySoundtrackModel({
    required this.album,
    this.gameName,
    this.gameId,
    this.youtubeUrl,
  });

  Soundtrack toEntity() {
    // Obtener cover URL
    String? coverUrl;
    if (album.images != null && album.images!.isNotEmpty) {
      coverUrl = album.images!.first.url;
    }

    // Extraer año del release date 
    int? year;
    if (album.releaseDate != null) {
      try {
        year = int.parse(album.releaseDate!.split('-').first);
      } catch (e) {
        // Ignorar si no se puede parsear
      }
    }

    // Extraer artistas/compositores
    final artists = album.artists
        ?.map((artist) => artist.name)
        .join(', ');

    // Extraer ID
    String soundtrackId = '';
    if (album.id != null) {
      soundtrackId = album.id;
    }

    // Extraer nombre
    String soundtrackName = 'Unknown Album';
    if (album.name != null) {
      soundtrackName = album.name;
    }

    // Extraer URL de Spotify
    String? spotifyUrl;
    if (album.externalUrls != null) {
      spotifyUrl = album.externalUrls!.spotify;
    }

    // Extraer información adicional si es Album completo
    int? popularity;
    int? totalTracks;
    String? label;
    List<Track> tracks = [];
    int? totalDurationMinutes;

    // Verificar si es Album completo (tiene más información)
    if (album is spotify.Album) {
      final fullAlbum = album as spotify.Album;
      
      popularity = fullAlbum.popularity;
      
      label = fullAlbum.label;
      
      if (fullAlbum.tracks != null) {
        final tracksList = fullAlbum.tracks!.toList();
        totalTracks = tracksList.length;
        
        // Parsear cada track
        int totalDurationMs = 0;
        for (var spotifyTrack in tracksList) {
          String trackName = 'Unknown Track';
          if (spotifyTrack.name != null) {
            trackName = spotifyTrack.name!;
          }
          
          int durationMs = 0;
          if (spotifyTrack.durationMs != null) {
            durationMs = spotifyTrack.durationMs!;
          }
          
          int trackNumber = 0;
          if (spotifyTrack.trackNumber != null) {
            trackNumber = spotifyTrack.trackNumber!;
          }
          
          String? previewUrl;
          if (spotifyTrack.previewUrl != null) {
            previewUrl = spotifyTrack.previewUrl;
          }
          
          final track = Track(
            name: trackName,
            durationMs: durationMs,
            trackNumber: trackNumber,
            previewUrl: previewUrl,
          );
          
          tracks.add(track);
          totalDurationMs = totalDurationMs + durationMs;
        }
        
        // Calcular duración total en minutos
        if (totalDurationMs > 0) {
          totalDurationMinutes = totalDurationMs ~/ 60000;
        }
      }
    }

    return Soundtrack(
      id: soundtrackId,
      name: soundtrackName,
      coverUrl: coverUrl,
      composer: artists,
      releaseYear: year,
      gameId: gameId,
      gameName: gameName,
      popularity: popularity,
      totalTracks: totalTracks,
      spotifyUrl: spotifyUrl,
      previewUrl: null,
      label: label,
      tracks: tracks,
      totalDurationMinutes: totalDurationMinutes,
      youtubeUrl: youtubeUrl,
    );
  }
}
