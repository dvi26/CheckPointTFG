import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router.dart';
import '../../../../app/widgets/widgets.dart';
import '../../../../app/theme/colors.dart';
import '../../domain/entities/soundtrack.dart';
import '../controllers/soundtrack_controller.dart';

/// Página de detalles de un soundtrack de videojuego.
/// Muestra información completa: portada, compositor, tracklist,
/// duración, y enlaces.
class SoundtrackDetailPage extends StatefulWidget {
  const SoundtrackDetailPage({
    super.key,
    required this.spotifyId,
    this.gameName,
    this.gameId,
  });

  final String spotifyId;
  final String? gameName;
  final int? gameId;

  @override
  State<SoundtrackDetailPage> createState() {
    return _SoundtrackDetailPageState();
  }
}

class _SoundtrackDetailPageState extends State<SoundtrackDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar detalles del soundtrack al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SoundtrackController>().loadSoundtrackDetails(
            widget.spotifyId,
            gameName: widget.gameName,
            gameId: widget.gameId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SoundtrackController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final soundtrack = controller.selectedSoundtrack;

          if (soundtrack == null) {
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
                  const Text('No se pudo cargar el soundtrack'),
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

          return _SoundtrackDetailContent(soundtrack: soundtrack);
        },
      ),
    );
  }
}

/// Widget que muestra el contenido completo de la página de detalles.
class _SoundtrackDetailContent extends StatelessWidget {
  const _SoundtrackDetailContent({required this.soundtrack});

  final Soundtrack soundtrack;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // AppBar con imagen de portada
        _buildAppBar(context),

        // Contenido principal
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  soundtrack.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSpotifyButton(context),

              const SizedBox(height: 12),

              _buildMainInfo(context),

              if (soundtrack.tracks.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTracklist(context),
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

  /// Construye el AppBar con la imagen de portada
  Widget _buildAppBar(BuildContext context) {
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
          imageUrl: soundtrack.coverUrl,
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

  /// Construye el botón para escuchar en Spotify.
  Widget _buildSpotifyButton(BuildContext context) {
    if (soundtrack.spotifyUrl == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FilledButton.icon(
        onPressed: () async {
          final url = soundtrack.spotifyUrl!;
          try {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo abrir Spotify'),
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al abrir Spotify'),
                ),
              );
            }
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.music_note),
        label: const Text('Escuchar en Spotify'),
      ),
    );
  }

  /// Construye la sección de información principal
  Widget _buildMainInfo(BuildContext context) {
    if (soundtrack.gameName == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DetailInfoRow(
        icon: Icons.videogame_asset,
        label: 'Juego',
        value: soundtrack.gameName!,
        onTap: soundtrack.gameId != null
            ? () {
                Navigator.of(context).pushNamed(
                  AppRouter.gameDetail,
                  arguments: soundtrack.gameId,
                );
              }
            : null,
      ),
    );
  }

  /// Construye la sección de tracklist
  Widget _buildTracklist(BuildContext context) {
    return ExpandableSection(
      title: 'Lista de canciones',
      initiallyExpanded: true,
      child: Column(
        children: [
          const SizedBox(height: 6),
          TrackList(tracks: soundtrack.tracks),
        ],
      ),
    );
  }

  /// Construye la sección de información adicional desplegable.
  Widget _buildAdditionalInfo(BuildContext context) {
    return ExpandableSection(
      title: 'Información adicional',
      child: Column(
        children: [
          if (soundtrack.composer != null)
            DetailInfoRow(
              icon: Icons.person,
              label: 'Compositor',
              value: soundtrack.composer!,
            ),
          if (soundtrack.releaseYear != null)
            DetailInfoRow(
              icon: Icons.calendar_today,
              label: 'Año de lanzamiento',
              value: '${soundtrack.releaseYear}',
            ),
          if (soundtrack.label != null)
            DetailInfoRow(
              icon: Icons.business,
              label: 'Sello discográfico',
              value: soundtrack.label!,
            ),
          if (soundtrack.totalDurationMinutes != null)
            DetailInfoRow(
              icon: Icons.timer,
              label: 'Duración total',
              value: soundtrack.formattedDuration,
            ),
          if (soundtrack.totalTracks != null)
            DetailInfoRow(
              icon: Icons.queue_music,
              label: 'Número de pistas',
              value: '${soundtrack.totalTracks}',
            ),
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
}
