import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Widget que muestra el rating con estrellas y número.
class RatingDisplay extends StatelessWidget {
  const RatingDisplay({
    super.key,
    required this.rating,
    this.ratingCount,
    this.size = RatingDisplaySize.medium,
  });

  final double rating;
  final int? ratingCount;
  final RatingDisplaySize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Ajustar tamaños según el tipo
    double numberFontSize;
    double labelFontSize;
    double starSize;
    
    if (size == RatingDisplaySize.large) {
      numberFontSize = 48;
      labelFontSize = 14;
      starSize = 24;
    } else if (size == RatingDisplaySize.small) {
      numberFontSize = 20;
      labelFontSize = 11;
      starSize = 14;
    } else {
      numberFontSize = 36;
      labelFontSize = 13;
      starSize = 20;
    }

    // Calcular estrellas (rating de 0 a 100, convertir a 0-5)
    final starRating = rating / 20;
    final fullStars = starRating.floor();
    final hasHalfStar = (starRating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Estrellas visuales
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(fullStars, (index) => Icon(
                    Icons.star_rounded,
                    color: colorScheme.primary,
                    size: starSize,
                  )),
              if (hasHalfStar)
                Icon(
                  Icons.star_half_rounded,
                  color: colorScheme.primary,
                  size: starSize,
                ),
              ...List.generate(emptyStars, (index) => Icon(
                    Icons.star_outline_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    size: starSize,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          // Número de rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: numberFontSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: numberFontSize * 0.4,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Label
          if (ratingCount != null)
            Text(
              '$ratingCount valoraciones',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: labelFontSize,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Valoración',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: labelFontSize,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// Tamaños disponibles para el RatingDisplay
enum RatingDisplaySize {
  small,
  medium,
  large,
}

