import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget que muestra una imagen hero con overlay y botón de favorito.
class DetailHeaderImage extends StatelessWidget {
  const DetailHeaderImage({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.onFavoritePressed,
    this.isFavorite = false,
  });

  final String? imageUrl;
  final double height;
  final VoidCallback? onFavoritePressed;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top + 5;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen principal
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
          ),
          child: imageUrl != null
              ? _ImageWithFallback(
                  primaryUrl: imageUrl!,
                  fallbackUrl: _getFallbackUrl(imageUrl!),
                  height: height,
                  colorScheme: colorScheme,
                )
              : SizedBox(
                  height: height,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
        ),

        // Gradient overlay 
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Botón de favorito
        if (onFavoritePressed != null)
          Positioned(
            top: topPadding,
            right: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onFavoritePressed,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? colorScheme.primary : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Obtiene la URL de fallback (cover_big normal si es cover_big_2x)
  String? _getFallbackUrl(String url) {
    if (url.contains('t_cover_big_2x')) {
      return url.replaceAll('t_cover_big_2x', 't_cover_big');
    }
    return null;
  }
}

/// Widget que intenta cargar una imagen de alta calidad y usa fallback si falla
class _ImageWithFallback extends StatefulWidget {
  const _ImageWithFallback({
    required this.primaryUrl,
    this.fallbackUrl,
    required this.height,
    required this.colorScheme,
  });

  final String primaryUrl;
  final String? fallbackUrl;
  final double height;
  final ColorScheme colorScheme;

  @override
  State<_ImageWithFallback> createState() => _ImageWithFallbackState();
}

class _ImageWithFallbackState extends State<_ImageWithFallback> {
  bool _hasError = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.primaryUrl;
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _currentUrl!,
      width: double.infinity,
      height: widget.height * 1.3, 
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      memCacheWidth: null,
      memCacheHeight: null,
      placeholder: (context, url) => SizedBox(
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(
            color: widget.colorScheme.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // Si hay fallback y aún no lo hemos intentado, usar fallback
        if (!_hasError && widget.fallbackUrl != null && _currentUrl == widget.primaryUrl) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _currentUrl = widget.fallbackUrl;
              });
            }
          });
          // Mostrar placeholder mientras carga el fallback
          return SizedBox(
            height: widget.height,
            child: Center(
              child: CircularProgressIndicator(
                color: widget.colorScheme.primary,
              ),
            ),
          );
        }
        
        // Si ya intentamos el fallback o no hay fallback, mostrar error
        return SizedBox(
          height: widget.height,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: widget.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}
