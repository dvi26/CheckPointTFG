import '../../domain/entities/game.dart';
import '../../../../core/utils/website_category_mapper.dart';
import '../../../../core/utils/platform_mapper.dart';

/// DTO para deserializar JSON de IGDB
class GameModel {
  final int id;
  final String name;
  final double? rating;
  final CoverModel? cover;
  final List<int>? genres;
  final int? firstReleaseDate;
  final String? summary;
  final int? ratingCount;
  final String? storyline;
  final List<int>? platforms;
  final List<InvolvedCompanyModel>? involvedCompanies;
  final List<WebsiteModel>? websites;
  final List<ScreenshotModel>? screenshots;

  const GameModel({
    required this.id,
    required this.name,
    this.rating,
    this.cover,
    this.genres,
    this.firstReleaseDate,
    this.summary,
    this.ratingCount,
    this.storyline,
    this.platforms,
    this.involvedCompanies,
    this.websites,
    this.screenshots,
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

    // Parsear rating count, convertir de num a int si existe
    int? ratingCount;
    if (json['rating_count'] != null) {
      ratingCount = (json['rating_count'] as num).toInt();
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

    // Parsear plataformas, convertir array de IDs si existe
    List<int>? platforms;
    if (json['platforms'] != null) {
      platforms = List<int>.from(json['platforms']);
    }

    // Parsear involved companies (desarrolladores y publishers)
    List<InvolvedCompanyModel>? involvedCompanies;
    if (json['involved_companies'] != null) {
      final companiesList = json['involved_companies'] as List<dynamic>;
      involvedCompanies = [];
      for (var companyJson in companiesList) {
        final companyModel = InvolvedCompanyModel.fromJson(companyJson);
        involvedCompanies.add(companyModel);
      }
    }

    // Parsear websites
    List<WebsiteModel>? websites;
    if (json['websites'] != null) {
      final websitesList = json['websites'] as List<dynamic>;
      websites = [];
      for (var websiteJson in websitesList) {
        final websiteModel = WebsiteModel.fromJson(websiteJson);
        websites.add(websiteModel);
      }
    }

    // Parsear screenshots
    List<ScreenshotModel>? screenshots;
    if (json['screenshots'] != null) {
      final screenshotsList = json['screenshots'] as List<dynamic>;
      screenshots = [];
      for (var screenshotJson in screenshotsList) {
        final screenshotModel = ScreenshotModel.fromJson(screenshotJson);
        screenshots.add(screenshotModel);
      }
    }

    return GameModel(
      id: json['id'] as int,
      name: json['name'] as String,
      rating: rating,
      cover: cover,
      genres: genres,
      firstReleaseDate: json['first_release_date'] as int?,
      summary: json['summary'] as String?,
      ratingCount: ratingCount,
      storyline: json['storyline'] as String?,
      platforms: platforms,
      involvedCompanies: involvedCompanies,
      websites: websites,
      screenshots: screenshots,
    );
  }

  /// Convierte el GameModel a Game 
  Game toEntity({
    Map<int, String>? genreMap,
    Map<int, String>? platformMap,
  }) {
    // Convertir timestamp Unix a año
    int? year;
    if (firstReleaseDate != null) {
      final milliseconds = firstReleaseDate! * 1000;
      final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      year = date.year;
    }

    // Convertir IDs de géneros a nombres
    List<String> genreNames = [];
    if (genres != null && genreMap != null) {
      for (int genreId in genres!) {
        String genreName = 'Unknown';
        if (genreMap.containsKey(genreId)) {
          genreName = genreMap[genreId]!;
        }
        genreNames.add(genreName);
      }
    }

    // Convertir IDs de plataformas a nombres
    List<String> platformNames = [];
    if (platforms != null) {
      for (int platformId in platforms!) {
        String platformName;
        
        if (platformMap != null && platformMap.containsKey(platformId)) {
          platformName = platformMap[platformId]!;
        } else {
          platformName = PlatformMapper.getPlatformName(platformId);
        }
        
        platformNames.add(platformName);
      }
    }

    // Separar developers y publishers de involved_companies
    List<String> developerNames = [];
    List<String> publisherNames = [];
    if (involvedCompanies != null) {
      for (var company in involvedCompanies!) {
        String companyName = company.companyName;
        
        // Verificar si es developer
        bool isDeveloper = false;
        if (company.developer != null) {
          isDeveloper = company.developer!;
        }
        
        // Verificar si es publisher
        bool isPublisher = false;
        if (company.publisher != null) {
          isPublisher = company.publisher!;
        }
        
        if (isDeveloper) {
          developerNames.add(companyName);
        }
        if (isPublisher) {
          publisherNames.add(companyName);
        }
      }
    }

    // Convertir WebsiteModel a GameWebsite
    List<GameWebsite> websiteList = [];
    if (websites != null) {
      for (var websiteModel in websites!) {
        final website = websiteModel.toEntity();
        websiteList.add(website);
      }
    }

    // Convertir ScreenshotModel a URLs
    List<String> screenshotUrls = [];
    if (screenshots != null) {
      for (var screenshotModel in screenshots!) {
        final url = screenshotModel.getImageUrl();
        screenshotUrls.add(url);
      }
    }

    // Convertir CoverModel a URL de imagen
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
      ratingCount: ratingCount,
      storyline: storyline,
      platforms: platformNames,
      developers: developerNames,
      publishers: publisherNames,
      websites: websiteList,
      screenshots: screenshotUrls,
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

/// Modelo para las compañías involucradas en el juego
class InvolvedCompanyModel {
  final String companyName;
  final bool? developer;
  final bool? publisher;

  const InvolvedCompanyModel({
    required this.companyName,
    this.developer,
    this.publisher,
  });

  factory InvolvedCompanyModel.fromJson(Map<String, dynamic> json) {
    // Extraer nombre de la compañía
    String name = 'Unknown Company';
    if (json['company'] != null) {
      final companyData = json['company'];
      if (companyData is Map && companyData['name'] != null) {
        name = companyData['name'] as String;
      }
    }

    return InvolvedCompanyModel(
      companyName: name,
      developer: json['developer'] as bool?,
      publisher: json['publisher'] as bool?,
    );
  }
}

/// Modelo para los sitios web del juego
class WebsiteModel {
  final int? category;
  final String url;

  const WebsiteModel({
    this.category,
    required this.url,
  });

  factory WebsiteModel.fromJson(Map<String, dynamic> json) {
    return WebsiteModel(
      category: json['type'] as int?,
      url: json['url'] as String,
    );
  }

  /// Convierte el WebsiteModel a GameWebsite
  GameWebsite toEntity() {
    // Mapear categoría numérica a nombre legible
    String categoryName = _getCategoryName(category);
    return GameWebsite(
      category: categoryName,
      url: url,
    );
  }

  /// Convierte el código de categoría IGDB a nombre legible
  String _getCategoryName(int? categoryCode) {
    return WebsiteCategoryMapper.getCategoryName(categoryCode);
  }
}

/// Modelo para las capturas de pantalla
class ScreenshotModel {
  final String imageId;

  const ScreenshotModel({required this.imageId});

  factory ScreenshotModel.fromJson(Map<String, dynamic> json) {
    return ScreenshotModel(
      imageId: json['image_id'] as String,
    );
  }

  /// Genera la URL de la imagen en alta calidad
  String getImageUrl({String size = 'screenshot_huge'}) {
    return 'https://images.igdb.com/igdb/image/upload/t_$size/$imageId.jpg';
  }
}
