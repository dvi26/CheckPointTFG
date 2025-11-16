import 'package:checkpoint/features/auth/presentation/pages/login_page.dart';
import 'package:checkpoint/features/auth/presentation/pages/register_page.dart';
import 'package:checkpoint/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/welcome_page.dart';

/// Router central con rutas con nombre y generador de páginas.
final class AppRouter {
  // Nombres de ruta.
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';

  /// Crea la ruta según [RouteSettings.name].
  ///
  /// Siempre devuelve un `Route` válido. Si la ruta no existe, usa un fallback.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Determinar qué pantalla mostrar según la ruta
    Widget page;
    
    switch (settings.name) {
      case welcome:
        page = const WelcomePage();
        break;

      case login:
        page = const LoginPage();
        break;

      case register:
        page = const RegisterPage();
        break;

      case home:
        page = const HomePage();
        break;

      default:
        // Si la ruta no existe, mostrar pantalla de error
        return _unknownRoute(settings);
    }
    
    // Crear la ruta con la pantalla correspondiente
    return _page(page, settings);
  }

  /// Helper para crear `MaterialPageRoute` con `settings`.
  static MaterialPageRoute _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return child;
      },
      settings: settings,
    );
  }

  /// Fallback cuando una ruta no existe.
  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    // Obtener el nombre de la ruta que no existe
    String routeName;
    if (settings.name != null) {
      routeName = settings.name!;
    } else {
      routeName = 'unknown';
    }
    
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return _NotFoundRoute(name: routeName);
      },
      settings: settings,
    );
  }
}

/// Pantalla para rutas no encontradas.
class _NotFoundRoute extends StatelessWidget {
  const _NotFoundRoute({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta no encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'No existe la ruta: $name',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Volver a la pantalla anterior
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder temporal para pantallas aún no implementadas.
// class _Placeholder extends StatelessWidget {
//   const _Placeholder({required this.title});

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: const Center(
//         child: Text('TODO'),
//       ),
//     );
//   }
// }
