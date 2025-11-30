import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    //final colorScheme = Theme.of(context).colorScheme;
    
    return StreamBuilder<AuthUser?>(
      stream: authController.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Error: Usuario no autenticado')),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Perfil'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _ProfileHeader(user: user)),
                const SizedBox(height: 32),
                const _ProfileStats(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AuthUser user;

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getHandle(AuthUser user) {
    if (user.displayName != null) {
      return '@${user.displayName!.toLowerCase().replaceAll(' ', '')}';
    }
    if (user.email != null) {
      return '@${user.email!.split('@')[0]}';
    }
    return '@user';
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión', textAlign: TextAlign.center),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.onSurface,
            foregroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    _getInitials(user.displayName),
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.surface,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'Usuario',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getHandle(user),
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.onBgTextWeak,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editar - Próximamente')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
                foregroundColor: colorScheme.surface,
                minimumSize: const Size(110, 44),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Editar perfil',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => _signOut(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparente para ver el fondo
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: AppColors.stroke.withValues(alpha: 0.8)),
                minimumSize: const Size(110, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            value: '8',
            label: 'Reviews',
            icon: Icons.star_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '3',
            label: 'Listas',
            icon: Icons.list_alt_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '4',
            label: 'Favs',
            icon: Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onBgTextWeak,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
