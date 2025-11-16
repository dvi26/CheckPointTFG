/// Entidad de una banda sonora de videojuego.
/// 
/// Representa la información de un soundtrack que se muestra en la UI.
/// Datos procesados y listos para usar (no depende de la API).
class Soundtrack {
  /// ID único de la banda sonora en Spotify.
  final String id;
  
  /// Nombre del álbum/soundtrack.
  final String name;
  
  /// URL de la imagen de portada del álbum.
  /// null si el álbum no tiene portada disponible.
  final String? coverUrl;
  
  /// Nombre del compositor o artista.
  /// Obtenido de los artistas del álbum en Spotify.
  /// null si no hay información de artista disponible.
  final String? composer;
  
  /// Año de lanzamiento del soundtrack.
  /// null si no hay fecha de lanzamiento disponible.
  final int? releaseYear;
  
  /// ID del videojuego asociado en IGDB.
  /// null si el soundtrack viene solo de Spotify sin asociación a juego.
  final int? gameId;
  
  /// Nombre del videojuego asociado.
  /// null si el soundtrack no está asociado a ningún juego.
  final String? gameName;
  
  /// Popularidad del álbum en Spotify (0-100).
  /// null si la información de popularidad no está disponible.
  /// Solo disponible en álbumes completos.
  final int? popularity;
  
  /// Número total de pistas/tracks del álbum.
  /// null si la información no está disponible.
  final int? totalTracks;
  
  /// URL para abrir el álbum en Spotify.
  /// null si la URL no está disponible.
  final String? spotifyUrl;

  /// URL de preview de audio.
  final String? previewUrl;

  const Soundtrack({
    required this.id,
    required this.name,
    this.coverUrl,
    this.composer,
    this.releaseYear,
    this.gameId,
    this.gameName,
    this.popularity,
    this.totalTracks,
    this.spotifyUrl,
    this.previewUrl,
  });
}
