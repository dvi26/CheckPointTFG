import 'package:flutter/material.dart';

/// Botón "Continuar con Google".
/// Conecta con la autenticación de Google.
class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.g_mobiledata,
            size: 24,
            color: cs.onSurface,
          ),
        ),
        label: const Text('Continuar con Google'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF262732)),
          foregroundColor: const Color(0xFFB7BAC4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
