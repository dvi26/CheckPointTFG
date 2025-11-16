import 'package:spotify/spotify.dart' as spotify;
import '../../domain/entities/soundtrack.dart';

/// Modelo para convertir datos de Spotify a nuestra entidad Soundtrack
class SpotifySoundtrackModel {
  final spotify.AlbumSimple album;
  final String? gameName;
  final int? gameId; 

  SpotifySoundtrackModel({
    required this.album,
    this.gameName,
    this.gameId,
  });

  Soundtrack toEntity() {
    String? coverUrl;
    if (album.images != null && album.images!.isNotEmpty) {
      // Spotify ordena por tamaño, tomamos la primera (más grande)
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

    final artists = album.artists
        ?.map((artist) => artist.name)
        .join(', ');

    String soundtrackId = '';
    if (album.id != null) {
      soundtrackId = album.id!;
    }

    String soundtrackName = 'Unknown Album';
    if (album.name != null) {
      soundtrackName = album.name!;
    }

    return Soundtrack(
      id: soundtrackId,
      name: soundtrackName,
      coverUrl: coverUrl,
      composer: artists,
      releaseYear: year,
      gameId: gameId,
      gameName: gameName,
      popularity: null, // AlbumSimple no tiene popularity, solo Album completo
      totalTracks: null, // Necesitaríamos hacer otra llamada para obtener esto
      spotifyUrl: album.externalUrls?.spotify,
      previewUrl: null, // Los álbumes no tienen preview, solo las tracks
    );
  }
}
