import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../router.dart';

/// Card de juego para mostrar en listas horizontales.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.gameId,
    required this.name,
    this.coverUrl,
    this.rating,
    this.genres = const [],
    this.year,
  });
  
  final int gameId;
  final String name;
  final String? coverUrl;
  final double? rating;
  final List<String> genres;
  final int? year;

  /// Construye el texto del subtítulo: "Género • Año", "Género", "Año" o ""
  String _buildGameSubtitle(List<String> genres, int? year) {
    String subtitle = '';
    
    if (genres.isNotEmpty) {
      subtitle = genres.first;
    }
    
    bool hasGenre = genres.isNotEmpty;
    bool hasYear = year != null;
    
    if (hasYear) {
      if (hasGenre) {
        subtitle = '$subtitle • $year';
      } else {
        subtitle = '$year';
      }
    }
    
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.gameDetail,
            arguments: gameId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  if (coverUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: coverUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.videogame_asset_rounded,
                            size: 56,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.videogame_asset_rounded,
                        size: 56,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  
                  if (rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _buildGameSubtitle(genres, year),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

