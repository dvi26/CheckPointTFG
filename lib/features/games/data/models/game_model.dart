import '../../domain/entities/game.dart';

/// DTO para deserializar JSON de IGDB
class GameModel {
  final int id;
  final String name;
  final double? rating;
  final CoverModel? cover;
  final List<int>? genres;
  final int? firstReleaseDate;
  final String? summary;

  const GameModel({
    required this.id,
    required this.name,
    this.rating,
    this.cover,
    this.genres,
    this.firstReleaseDate,
    this.summary,
  });

  /// Crea un GameModel desde JSON de IGDB
  /// 
  /// Parsea el JSON recibido de la API IGDB y crea un GameModel.
  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Parsear rating, convertir de num a double si existe
    double? rating;
    if (json['rating'] != null) {
      rating = (json['rating'] as num).toDouble();
    }

    // Parsear cover, crear CoverModel si existe
    CoverModel? cover;
    if (json['cover'] != null) {
      cover = CoverModel.fromJson(json['cover']);
    }

    // Parsear géneros, convertir array de IDs si existe
    List<int>? genres;
    if (json['genres'] != null) {
      genres = List<int>.from(json['genres']);
    }

    return GameModel(
      id: json['id'] as int,
      name: json['name'] as String,
      rating: rating,
      cover: cover,
      genres: genres,
      firstReleaseDate: json['first_release_date'] as int?,
      summary: json['summary'] as String?,
    );
  }

  /// Convierte el GameModel a Game 
  Game toEntity({Map<int, String>? genreMap}) {
    // Convertir timestamp Unix a año
    // La API nos da un número como 1431993600 (segundos desde 1970)
    // Lo convertimos a un año legible como 2015
    int? year;
    if (firstReleaseDate != null) {
      // Multiplicar por 1000 porque DateTime usa milisegundos, no segundos
      final milliseconds = firstReleaseDate! * 1000;
      final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      year = date.year;
    }

    // Convertir IDs de géneros a nombres
    // La API nos da una lista de números: [12, 31, 5]
    // Los convertimos a nombres: ["RPG", "Adventure", "Shooter"]
    List<String> genreNames = [];
    if (genres != null && genreMap != null) {
      for (int genreId in genres!) {
        // Buscar el nombre en el mapa, o usar "Unknown" si no existe
        String genreName = 'Unknown';
        if (genreMap.containsKey(genreId)) {
          genreName = genreMap[genreId]!;
        }
        genreNames.add(genreName);
      }
    }

    // Convertir CoverModel a URL de imagen
    // Si tenemos cover, llamar a su método getImageUrl()
    // Si no hay cover, coverUrl será null
    String? coverUrl;
    if (cover != null) {
      coverUrl = cover!.getImageUrl();
    }

    // Crear la entidad Game con los datos procesados
    return Game(
      id: id,
      name: name,
      rating: rating,
      coverUrl: coverUrl,
      genres: genreNames,
      releaseYear: year,
      summary: summary,
    );
  }
}

/// Modelo para las portadas de juegos
class CoverModel {
  final String imageId;

  const CoverModel({required this.imageId});

  factory CoverModel.fromJson(Map<String, dynamic> json) {
    return CoverModel(
      imageId: json['image_id'] as String,
    );
  }

  /// Genera la URL de la imagen en diferentes tamaños
  String getImageUrl({String size = 'cover_big'}) {
    return 'https://images.igdb.com/igdb/image/upload/t_$size/$imageId.jpg';
  }
}
