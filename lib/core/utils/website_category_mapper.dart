import 'package:flutter/material.dart';

/// Helper para mapear códigos de categoría de websites de IGDB a nombres e iconos.
/// 
/// Este archivo centraliza toda la lógica de mapeo de categorías para evitar
/// código duplicado en diferentes partes de la aplicación.
class WebsiteCategoryMapper {
  static const Map<int, String> _codeToName = {
    1: 'official',
    2: 'wikia',
    3: 'wikipedia',
    4: 'facebook',
    5: 'twitter',
    6: 'twitch',
    8: 'instagram',
    9: 'youtube',
    13: 'steam',
    14: 'reddit',
    15: 'itch',
    16: 'epic',
    17: 'gog',
    18: 'discord',
    19: 'bluesky',
    22: 'xbox',
    23: 'playstation',
    24: 'nintendo',
  };

  static const Map<String, String> _nameToDisplayName = {
    'official': 'Sitio oficial',
    'wikia': 'Wiki',
    'wikipedia': 'Wikipedia',
    'facebook': 'Facebook',
    'twitter': 'Twitter',
    'twitch': 'Twitch',
    'instagram': 'Instagram',
    'youtube': 'YouTube',
    'steam': 'Steam',
    'reddit': 'Reddit',
    'discord': 'Discord',
    'gog': 'GOG',
    'epic': 'Epic Games',
    'itch': 'Itch.io',
    'bluesky': 'Bluesky',
    'xbox': 'Xbox',
    'playstation': 'PlayStation',
    'nintendo': 'Nintendo',
    'other': 'Enlace externo',
  };

  static const Map<String, IconData> _nameToIcon = {
    'official': Icons.language,
    'wikia': Icons.article,
    'wikipedia': Icons.article,
    'facebook': Icons.facebook,
    'twitter': Icons.tag,
    'twitch': Icons.videocam,
    'instagram': Icons.camera_alt,
    'youtube': Icons.play_circle_outline,
    'steam': Icons.shopping_cart,
    'reddit': Icons.forum,
    'discord': Icons.chat,
    'gog': Icons.shopping_cart,
    'epic': Icons.shopping_cart,
    'itch': Icons.shopping_bag,
    'bluesky': Icons.cloud,
    'xbox': Icons.sports_esports,
    'playstation': Icons.sports_esports,
    'nintendo': Icons.sports_esports,
  };

  /// Convierte el código numérico de IGDB al nombre interno de la categoría.
  /// 
  /// Si el código es null o no existe en el mapa, retorna 'other'.

  static String getCategoryName(int? categoryCode) {
    if (categoryCode == null) {
      return 'other';
    }

    final name = _codeToName[categoryCode];
    
    if (name == null) {
      return 'other';
    }
    
    return name;
  }

  /// Convierte el nombre interno de la categoría al nombre que se muestra al usuario.
  /// 
  /// Si el nombre no existe en el mapa, retorna el mismo nombre que recibió.
  static String getDisplayName(String category) {
    final displayName = _nameToDisplayName[category];
    
    if (displayName == null) {
      return category;
    }
    
    return displayName;
  }

  /// Obtiene el icono que corresponde a una categoría.
  /// 
  /// Si la categoría no existe en el mapa, retorna Icons.link como icono por defecto.
  static IconData getIcon(String category) {
    final icon = _nameToIcon[category];
    
    if (icon == null) {
      return Icons.link;
    }
    
    return icon;
  }
}

