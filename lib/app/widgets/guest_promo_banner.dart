import 'package:flutter/material.dart';
import '../router.dart';

/// Banner promocional para usuarios invitados.
/// Muestra un mensaje para animar a crear cuenta.
class GuestPromoBanner extends StatelessWidget {
  const GuestPromoBanner({super.key});

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

