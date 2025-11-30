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
  
  /// Sello discográfico que publicó el soundtrack.
  /// null si no hay información disponible.
  final String? label;
  
  /// Lista de canciones del soundtrack.
  /// Incluye nombre, duración y número de track.
  /// Lista vacía si no hay información de tracks.
  final List<Track> tracks;
  
  /// Duración total del soundtrack en minutos.
  /// Calculada sumando la duración de todos los tracks.
  /// null si no hay información disponible.
  final int? totalDurationMinutes;
  
  /// URL para escuchar en Youtube.
  /// null si no hay link disponible.
  /// 
  /// TODO: Implementar botón "Ver en YouTube" en la UI del soundtrack detail
  final String? youtubeUrl;

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
    this.label,
    this.tracks = const [],
    this.totalDurationMinutes,
    this.youtubeUrl,
  });
  
  /// Devuelve la duración total formateada como "1h 30min" o "45min".
  String get formattedDuration {
    String formatted = 'N/A';
    if (totalDurationMinutes == null) {
      return formatted;
    }
    
    final hours = totalDurationMinutes! ~/ 60;
    final minutes = totalDurationMinutes! % 60;
    
    if (hours > 0) {
      formatted = '${hours}h';
      if (minutes > 0) {
        formatted = '$formatted ${minutes}min';
      }
    } else {
      formatted = '${minutes}min';
    }
    
    return formatted;
  }
}

/// Representa una canción individual de un soundtrack.
class Track {
  /// Nombre de la canción.
  final String name;
  
  /// Duración en milisegundos.
  final int durationMs;
  
  /// Número de la pista en el álbum (1, 2, 3...).
  final int trackNumber;
  
  /// URL de preview de 30 segundos (si está disponible).
  final String? previewUrl;

  const Track({
    required this.name,
    required this.durationMs,
    required this.trackNumber,
    this.previewUrl,
  });
  
  /// Devuelve la duración formateada como "3:45".
  String get formattedDuration {

    final minutes = durationMs ~/ 60000;
    
    final seconds = (durationMs % 60000) ~/ 1000;
    
    String secondsStr = seconds.toString();
    if (seconds < 10) {
      secondsStr = '0$seconds';
    }
    
    final formattedTime = '$minutes:$secondsStr';
    
    return formattedTime;
  }
}
