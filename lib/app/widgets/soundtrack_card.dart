import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../router.dart';

/// Card de soundtrack para mostrar en listas horizontales.
class SoundtrackCard extends StatelessWidget {
  const SoundtrackCard({
    super.key,
    required this.spotifyId,
    required this.name,
    this.coverUrl,
    this.gameName,
    this.gameId,
    this.composer,
    this.width = 160,
    this.imageHeight = 130,
    this.margin = const EdgeInsets.only(right: 16),
  });
  
  final String spotifyId;
  final String name;
  final String? coverUrl;
  final String? gameName;
  final int? gameId;
  final String? composer;
  final double? width;
  final double? imageHeight;
  final EdgeInsetsGeometry? margin;

  /// Construye el texto del subtítulo: prioridad gameName, luego composer, o vacío
  String _buildSoundtrackSubtitle(String? gameName, String? composer) {
    String subtitle = '';
    
    bool hasGameName = false;
    if (gameName != null) {
      hasGameName = true;
    }
    
    bool hasComposer = false;
    if (composer != null) {
      hasComposer = true;
    }
    
    if (hasGameName) {
      subtitle = gameName!;
    } else if (hasComposer) {
      subtitle = composer!;
    }
    
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      width: width,
      margin: margin,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.soundtrackDetail,
            arguments: {
              'spotifyId': spotifyId,
              'gameName': gameName,
              'gameId': gameId,
            },
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              width: width,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: coverUrl!,
                        width: width,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.album_rounded,
                            size: 48,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.album_rounded,
                        size: 48,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
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
              _buildSoundtrackSubtitle(gameName, composer),
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
