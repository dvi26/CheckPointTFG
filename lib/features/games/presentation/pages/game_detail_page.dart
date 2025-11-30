import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/widgets/widgets.dart';
import '../../../../app/theme/colors.dart';
import '../../../../core/utils/website_category_mapper.dart';
import '../../domain/entities/game.dart';
import '../controllers/game_controller.dart';

/// Página de detalles de un videojuego.
/// Muestra información completa: portada, rating, descripción, plataformas,
/// desarrolladores, screenshots, y enlaces.
class GameDetailPage extends StatefulWidget {
  const GameDetailPage({
    super.key,
    required this.gameId,
  });

  final int gameId;

  @override
  State<GameDetailPage> createState() {
    return _GameDetailPageState();
  }
}

class _GameDetailPageState extends State<GameDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().loadGameDetails(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final game = controller.selectedGame;

          if (game == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text('No se pudo cargar el juego'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return _GameDetailContent(game: game);
        },
      ),
    );
  }
}

/// Widget que muestra el contenido completo de la página de detalles.
class _GameDetailContent extends StatelessWidget {
  const _GameDetailContent({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  game.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              if (game.genres.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: game.genres.map((genre) {
                      return GenreTag(label: genre);
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              _buildAddToListButton(context),

              const SizedBox(height: 12),

              _buildMainInfo(context),

              if (game.summary != null) ...[
                const SizedBox(height: 12),
                _buildSummary(context),
              ],

              if (game.storyline != null) ...[
                const SizedBox(height: 12),
                _buildStoryline(context),
              ],

              if (game.screenshots.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildScreenshots(context),
              ],

              const SizedBox(height: 12),

              _buildAdditionalInfo(context),

              const SizedBox(height: 20),

              _buildActivitySection(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el AppBar con la imagen de portada del juego.
  /// Utiliza una imagen en alta calidad (cover_big_2x) para mejor resolución.
  Widget _buildAppBar(BuildContext context) {
    final highQualityImageUrl = _getHighQualityImageUrl();
    
    return SliverAppBar(
      expandedHeight: 550,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: DetailHeaderImage(
          imageUrl: highQualityImageUrl,
          height: 550,
          onFavoritePressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Favoritos - Próximamente'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Obtiene la URL de la imagen en alta calidad.
  /// Intenta usar cover_big_2x (retina, 528x748px) para mejor calidad visual.
  String? _getHighQualityImageUrl() {
    if (game.coverUrl == null) {
      return null;
    }
    
    if (game.coverUrl!.contains('t_cover_big')) {
      return game.coverUrl!.replaceAll('t_cover_big', 't_cover_big_2x');
    }
    
    return game.coverUrl;
  }

  /// Construye la sección de rating del juego.
  Widget _buildMainInfo(BuildContext context) {
    if (game.rating == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RatingDisplay(
          rating: game.rating!,
          ratingCount: game.ratingCount,
          size: RatingDisplaySize.large,
        ),
      ),
    );
  }

  /// Construye el botón para añadir el juego a una lista personalizada.
  Widget _buildAddToListButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FilledButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Añadir a lista - Próximamente'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
        ),
        child: const Text('Añadir a lista'),
      ),
    );
  }

  /// Construye la sección de descripción del juego.
  Widget _buildSummary(BuildContext context) {
    return DetailSection(
      title: 'Descripción',
      child: Text(
        game.summary!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
      ),
    );
  }

  /// Construye la sección de historia del juego (expandible).
  Widget _buildStoryline(BuildContext context) {
    return ExpandableSection(
      title: 'Historia',
      child: Text(
        game.storyline!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
      ),
    );
  }

  /// Construye la galería de capturas de pantalla del juego.
  Widget _buildScreenshots(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Capturas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ScreenshotGallery(screenshots: game.screenshots),
      ],
    );
  }

  /// Construye la sección de información adicional desplegable.
  /// Incluye año de lanzamiento, plataformas, desarrolladores y distribuidores.
  Widget _buildAdditionalInfo(BuildContext context) {
    return ExpandableSection(
      title: 'Información adicional',
      child: Column(
        children: [
          if (game.releaseYear != null)
            DetailInfoRow(
              icon: Icons.calendar_today,
              label: 'Año de lanzamiento',
              value: '${game.releaseYear}',
            ),
          if (game.platforms.isNotEmpty)
            DetailInfoRow(
              icon: Icons.devices,
              label: 'Plataformas',
              value: game.platforms.join(', '),
            ),
          if (game.developers.isNotEmpty)
            DetailInfoRow(
              icon: Icons.code,
              label: 'Desarrolladores',
              value: game.developers.join(', '),
            ),
          if (game.publishers.isNotEmpty)
            DetailInfoRow(
              icon: Icons.business,
              label: 'Distribuidores',
              value: game.publishers.join(', '),
            ),
          if (game.websites.isNotEmpty)
            ...game.websites.map((website) {
              return DetailInfoRow(
                icon: _getWebsiteIcon(website.category),
                label: _getWebsiteCategoryName(website.category),
                onTap: () => _launchWebsiteUrl(context, website.url),
              );
            }),
        ],
      ),
    );
  }

  /// Construye la sección de actividad de la comunidad.
  Widget _buildActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Actividad de la Comunidad',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ActivityList(itemCount: 3),
        ),
      ],
    );
  }

  /// Obtiene el nombre de la categoría de sitio web en español.
  String _getWebsiteCategoryName(String category) {
    return WebsiteCategoryMapper.getDisplayName(category);
  }

  /// Obtiene el icono según la categoría de sitio web.
  IconData _getWebsiteIcon(String category) {
    return WebsiteCategoryMapper.getIcon(category);
  }

  /// Abre un enlace web en una aplicación externa.
  Future<void> _launchWebsiteUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    
    bool canLaunch = false;
    try {
      canLaunch = await canLaunchUrl(uri);
    } catch (e) {
      canLaunch = false;
    }

    if (!canLaunch) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace'),
          ),
        );
      }
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al abrir el enlace'),
          ),
        );
      }
    }
  }
}
