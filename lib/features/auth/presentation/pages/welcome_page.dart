import 'package:flutter/material.dart';
import 'package:checkpoint/app/router.dart';
import 'package:checkpoint/app/widgets/widgets.dart';

/// Pantalla de bienvenida.
///
/// Presenta la marca y tres acciones principales:
/// 1) Registrarse  2) Iniciar sesión  3) Continuar sin cuenta (invitado).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              /// Encabezado: icono + nombre de la app.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.headphones_outlined,
                    size: 40,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: textTheme.headlineMedium?.copyWith(
                        letterSpacing: -0.3,
                      ),
                      children: [
                        const TextSpan(text: 'Check'),
                        TextSpan(
                          text: 'Point',
                          style: TextStyle(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Descubre, cataloga y comenta videojuegos y sus bandas sonoras.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),

              const Spacer(),

              /// Registro.
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.register),
                child: const Text('Registrarse'),
              ),

              const SizedBox(height: 12),

              /// Iniciar sesión: estilo lo aporta el theme (no in-line).
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C23),
                  foregroundColor: colorScheme.onSurface,
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.login),
                child: const Text('Iniciar sesión'),
              ),

              const SizedBox(height: 12),

              /// Modo invitado
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.home,
                  (route) => false,
                ),
                child: const Text('Continuar sin cuenta'),
              ),

              const SizedBox(height: 20),

              /// Separador.
              Opacity(
                opacity: .5,
                child: Container(
                  height: 1,
                  color: const Color(0xFF262732),
                ),
              ),

              const SizedBox(height: 8),

              Opacity(
                opacity: .7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Botón de iniciar con Google.
              GoogleButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Google: conectando... (no implementado)',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

