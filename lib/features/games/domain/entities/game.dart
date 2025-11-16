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

  const Game({
    required this.id,
    required this.name,
    this.rating,
    this.coverUrl,
    this.genres = const [],
    this.releaseYear,
    this.summary,
  });
}
