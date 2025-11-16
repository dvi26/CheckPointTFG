import 'package:firebase_auth/firebase_auth.dart';
import '../core/api/igdb_client.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/games/data/repositories/game_repository_impl.dart';
import '../features/games/presentation/controllers/game_controller.dart';
import '../features/soundtracks/data/repositories/soundtrack_repository_impl.dart';
import '../features/soundtracks/data/repositories/spotify_repository_impl.dart';
import '../features/soundtracks/presentation/controllers/soundtrack_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'theme/theme.dart';

/// Widget raíz de la app.
///
/// Configura el tema global y la resolución de rutas mediante
/// [AppRouter.onGenerateRoute]. La pantalla inicial se define en
/// [initialRoute]. Crea la lista de controladores para que las vistas
/// los usen.
class App extends StatelessWidget {
  const App({super.key, required this.initialRoute});
  
  final String initialRoute;

/// Construye el árbol de widgets de nivel superior.
  @override
  Widget build(BuildContext context) {
    // Crear repositorio de autenticación (Firebase)
    final firebaseAuth = FirebaseAuth.instance;
    final authRepository = FirebaseAuthRepository(firebaseAuth);

    // Crear API Clients (IGDB para juegos, Spotify para soundtracks)
    final igdbClient = IgdbClient();
    final gameRepository = GameRepositoryImpl(igdbClient);

    // Repositorios de soundtracks (IGDB + Spotify)
    final spotifyRepository = SpotifyRepositoryImpl();
    final soundtrackRepository = SoundtrackRepositoryImpl(igdbClient, spotifyRepository);
    
    return MultiProvider(
      // Lista de controladores para la app.
      providers: [
  // Maneja si el usuario está logueado o no.
  ChangeNotifierProvider(
    create: (context) {
      return AuthController(authRepository);
    },
  ),
  
  // Carga los juegos, filtra y notifica.
  ChangeNotifierProvider(
    create: (context) {
      return GameController(gameRepository);
    },
  ),

  // Carga las bandas sonoras, filtra y notifica.
  ChangeNotifierProvider(
    create: (context) {
      return SoundtrackController(soundtrackRepository);
    },
  ),
],
      child: MaterialApp(
        title: 'CheckPoint',
        theme: checkpointTheme(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: initialRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
