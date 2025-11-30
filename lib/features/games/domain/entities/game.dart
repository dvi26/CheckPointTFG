/// Entidad de un videojuego.
/// 
/// Representa la información de un juego que se muestra en la UI.
/// Datos procesados y listos para usar (no depende de la API).
class Game {  
  /// ID único del juego en la base de datos de IGDB.
  final int id;
  
  /// Nombre del videojuego.
  final String name;
  
  /// Lista de géneros del juego.
  /// Si el juego no tiene géneros asignados, esta lista estará vacía.
  final List<String> genres;
  
  /// Calificación del juego (0-100).
  /// null si el juego aún no tiene suficientes reviews.
  final double? rating;
  
  /// URL de la imagen de portada del juego.
  /// null si el juego no tiene portada disponible.
  final String? coverUrl;
  
  /// Año de lanzamiento del juego.
  /// null si el juego no ha salido aún (TBA - To Be Announced).
  final int? releaseYear;
  
  /// Descripción/sinopsis del juego.
  /// null si no hay descripción disponible.
  final String? summary;
  
  /// Número de personas que votaron el rating.
  /// null si no hay datos de votos disponibles.
  final int? ratingCount;
  
  /// Historia del juego (más detallada que summary).
  /// null si no hay storyline disponible.
  final String? storyline;
  
  /// Lista de plataformas donde está disponible el juego.
  /// Lista vacía si no hay información de plataformas.
  final List<String> platforms;
  
  /// Lista de desarrolladores del juego.
  /// Lista vacía si no hay información de desarrolladores.
  final List<String> developers;
  
  /// Lista de distribuidores/editores del juego.
  /// Lista vacía si no hay información de publishers.
  final List<String> publishers;
  
  /// Lista de URLs de sitios web relacionados con el juego.
  /// Incluye web oficial, Steam, Epic Games, etc.
  /// Lista vacía si no hay websites disponibles.
  final List<GameWebsite> websites;
  
  /// Lista de URLs de capturas de pantalla del juego.
  /// null si no hay screenshots disponibles.
  final List<String> screenshots;

  const Game({
    required this.id,
    required this.name,
    this.rating,
    this.coverUrl,
    this.genres = const [],
    this.releaseYear,
    this.summary,
    this.ratingCount,
    this.storyline,
    this.platforms = const [],
    this.developers = const [],
    this.publishers = const [],
    this.websites = const [],
    this.screenshots = const [],
  });
}

/// Representa un sitio web relacionado con el juego.
class GameWebsite {
  /// Categoría del sitio web.
  final String category;
  
  /// URL del sitio web.
  final String url;

  const GameWebsite({
    required this.category,
    required this.url,
  });
}
