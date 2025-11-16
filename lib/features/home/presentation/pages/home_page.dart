import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/router.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../games/presentation/controllers/game_controller.dart';
import '../../../soundtracks/presentation/controllers/soundtrack_controller.dart';

/// Pantalla principal de la aplicación.
/// Muestra diferentes secciones según si el usuario está autenticado o es invitado.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    
    return StreamBuilder<AuthUser?>(
      stream: authController.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrar loading mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        final isGuest = user == null;

        // Pantallas disponibles según tipo de usuario
        final screens = [
          _FeedScreen(isGuest: isGuest),
          _SearchScreen(isGuest: isGuest),
          if (!isGuest) ...[
            const _LibraryScreen(),
            const _ProfileScreen(),
          ],
        ];

        // Ajustar índice si cambió el número de pantallas
        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Buscar',
              ),
              // Solo usuarios autenticados ven Biblioteca y Perfil
              if (!isGuest) ...[
                const NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music),
                  label: 'Biblioteca',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Pantalla de Feed/Inicio
class _FeedScreen extends StatefulWidget {
  const _FeedScreen({required this.isGuest});

  final bool isGuest;

  @override
  State<_FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<_FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar juegos y soundtracks populares al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().loadPopularGames();
      context.read<SoundtrackController>().loadPopularSoundtracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Icon(
                Icons.headphones_outlined,
                size: 28,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: 'Check',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    TextSpan(
                      text: 'Point',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Solo usuarios autenticados ven notificaciones
            if (!widget.isGuest)
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificaciones - Próximamente')),
                  );
                },
              ),
          ],
        ),

        // Mensaje para usuarios invitados
        if (widget.isGuest)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Inicia sesión para guardar juegos, crear listas y más',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'Juegos Populares',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              const _HorizontalGameList(),

              const SizedBox(height: 32),

              _SectionHeader(
                title: 'Soundtracks del Momento',
                subtitle: 'Lo más escuchado esta semana',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              const _HorizontalSoundtrackList(),

              const SizedBox(height: 32),

              _SectionHeader(
                title: 'Actividad de la Comunidad',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              const _RecentActivityList(),
              
              const SizedBox(height: 32),
              
              if (widget.isGuest) _GuestPromoBanner(),
              
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.onSeeAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Ver todo'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lista horizontal de juegos
class _HorizontalGameList extends StatelessWidget {
  const _HorizontalGameList();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final games = controller.popularGames;

        if (games.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: Text('No se pudieron cargar los juegos'),
            ),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final game = games[index];
              return _GameCard(
                name: game.name,
                coverUrl: game.coverUrl,
                rating: game.rating,
                genres: game.genres,
                year: game.releaseYear,
              );
            },
          ),
        );
      },
    );
  }
}

/// Card de juego individual
class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.name,
    this.coverUrl,
    this.rating,
    this.genres = const [],
    this.year,
  });
  
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name - Próximamente')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del juego (imagen real o placeholder)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Imagen de portada
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
            // Mostrar género y año del juego
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

/// Lista horizontal de soundtracks 
class _HorizontalSoundtrackList extends StatelessWidget {
  const _HorizontalSoundtrackList();

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundtrackController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final soundtracks = controller.popularSoundtracks;

        if (soundtracks.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('No se pudieron cargar los soundtracks'),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: soundtracks.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final soundtrack = soundtracks[index];
              return _SoundtrackCard(
                name: soundtrack.name,
                coverUrl: soundtrack.coverUrl,
                gameName: soundtrack.gameName,
                composer: soundtrack.composer,
              );
            },
          ),
        );
      },
    );
  }
}

/// Card de soundtrack individual
class _SoundtrackCard extends StatelessWidget {
  const _SoundtrackCard({
    required this.name,
    this.coverUrl,
    this.gameName,
    this.composer,
  });
  
  final String name;
  final String? coverUrl;
  final String? gameName;
  final String? composer;

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
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name - Próximamente')),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del soundtrack (imagen real o placeholder)
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: coverUrl!,
                        width: 160,
                        height: 130,
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
            // Mostrar juego asociado o compositor (prioridad al juego)
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

/// Lista de actividad reciente 
class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => const _ActivityItem()),
    );
  }
}

/// Item de actividad
class _ActivityItem extends StatelessWidget {
  const _ActivityItem();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario valoró un juego',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'hace 2 horas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de búsqueda
class _SearchScreen extends StatelessWidget {
  const _SearchScreen({required this.isGuest});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Pantalla de búsqueda - Por implementar'),
      ),
    );
  }
}

/// Pantalla de biblioteca
class _LibraryScreen extends StatelessWidget {
  const _LibraryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Tus listas y juegos guardados - Por implementar'),
      ),
    );
  }
}

/// Pantalla de perfil con información del usuario
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    
    return StreamBuilder<AuthUser?>(
      stream: authController.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrar loading mientras se carga el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Perfil'),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            automaticallyImplyLeading: false,
          ),
          body: user != null
              ? _UserProfileView(user: user)
              : const Center(child: Text('Error: No debería llegar aquí')),
        );
      },
    );
  }
}

// _GuestProfileView actualmente inaccesible porque invitados no ven tab de Perfil.
/*
/// Widget para mostrar el perfil de un usuario invitado
class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'Modo Invitado',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Inicia sesión para guardar tus juegos, crear listas y escribir reseñas',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.welcome,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/// Widget para mostrar el perfil de un usuario autenticado
class _UserProfileView extends StatelessWidget {
  const _UserProfileView({required this.user});

  final AuthUser user;

  String _getDisplayName(String? displayName) {
    String name = 'Usuario';
    
    bool hasDisplayName = false;
    if (displayName != null) {
      hasDisplayName = true;
    }
    
    if (hasDisplayName) {
      name = displayName!;
    }
    
    return name;
  }

  String _getEmailOrEmpty(String? email) {
    String emailText = ''; 
    
    bool hasEmail = false;
    if (email != null) {
      hasEmail = true;
    }
    
    if (hasEmail) {
      emailText = email!;
    }
    
    return emailText;
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authController = context.read<AuthController>();
      await authController.signOut();
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.welcome,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 32),
        
        Center(
          child: Column(
            children: [
              Text(
                _getDisplayName(user.displayName),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getEmailOrEmpty(user.email),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

/// Banner promocional para usuarios invitados
class _GuestPromoBanner extends StatelessWidget {
  const _GuestPromoBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.star_rounded,
            size: 48,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Desbloquea todo el potencial!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu cuenta para guardar juegos, escribir reseñas, crear listas personalizadas y mucho más.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.welcome,
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Crear cuenta gratis'),
            ),
          ),
        ],
      ),
    );
  }
}

