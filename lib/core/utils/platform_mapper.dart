/// Helper para mapear IDs de plataformas de IGDB a nombres en español.
/// 
/// Este archivo gestiona el mapeo de plataformas, permitiendo una lista dinámica
/// actualizada desde la API de IGDB.
class PlatformMapper {
  static Map<int, String> _idToName = {};

  /// Inicializa o actualiza el mapa de plataformas.
  /// 
  /// Este método debe ser llamado desde el repositorio cuando se cargan las plataformas.
  static void updatePlatforms(Map<int, String> platforms) {
    // Si la nueva lista está vacía, no sobrescribimos con nada (mantenemos lo que hubiera)
    // o podríamos decidir limpiar. Asumiremos que si viene algo, actualizamos.
    if (platforms.isNotEmpty) {
      _idToName = Map.from(platforms);
    }
  }

  /// Obtiene el nombre de la plataforma según su ID de IGDB.
  /// 
  /// Si el ID no existe en el mapa, retorna 'Plataforma desconocida'.
  static String getPlatformName(int platformId) {
    final name = _idToName[platformId];
    
    if (name == null) {
      // Como fallback temporal podríamos retornar el ID en string para debug
      // pero mantenemos el comportamiento anterior
      return 'Plataforma desconocida';
    }
    
    return name;
  }

  /// Verifica si una plataforma está mapeada.
  static bool isMapped(int platformId) {
    return _idToName.containsKey(platformId);
  }
}
