import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router.dart';
import '../../../../app/widgets/widgets.dart';
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
              SectionHeader(
                title: 'Juegos Populares',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              const _HorizontalGameList(),

              const SizedBox(height: 32),

              SectionHeader(
                title: 'Soundtracks del Momento',
                subtitle: 'Lo más escuchado esta semana',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              const _HorizontalSoundtrackList(),

              const SizedBox(height: 32),

              SectionHeader(
                title: 'Actividad de la Comunidad',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              const ActivityList(itemCount: 3),
              
              const SizedBox(height: 32),
              
              if (widget.isGuest) const GuestPromoBanner(),
              
              const SizedBox(height: 24),
            ]),
          ),
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
              return GameCard(
                gameId: game.id,
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
              return SoundtrackCard(
                spotifyId: soundtrack.id,
                name: soundtrack.name,
                coverUrl: soundtrack.coverUrl,
                gameName: soundtrack.gameName,
                gameId: soundtrack.gameId,
                composer: soundtrack.composer,
              );
            },
          ),
        );
      },
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
