import 'package:flutter/material.dart';
import 'package:checkpoint/app/router.dart';
import 'package:provider/provider.dart';
import 'package:checkpoint/features/auth/presentation/controllers/auth_controller.dart';

/// Pantalla de inicio de sesión.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Limpiar error cuando el usuario empieza a escribir
    _emailCtrl.addListener(_onTextChanged);
    _passCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      context.read<AuthController>().clearError();
    }
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_onTextChanged);
    _passCtrl.removeListener(_onTextChanged);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    String? msg;
    
    String value = '';
    if (v != null) {
      value = v.trim();
    }
    
    if (value.isEmpty){
      msg='Introduce tu email.';
    }
    else if (!value.contains('@') || !value.contains('.')) {
      msg= 'Email no válido.';
    }
    return msg;
  }

  String? _validatePassword(String? v) {
    String? msg;
    
    String value = '';
    if (v != null) {
      value = v;
    }
    
    if (value.isEmpty) {
      msg='Introduce tu contraseña.';
    }
    else if (value.length < 6)
      {
        msg='Mínimo 6 caracteres.';
      }
    return msg;
  }

  /// Devuelve el tooltip del botón de visibilidad de contraseña
  String _getPasswordVisibilityTooltip() {
    String tooltip = 'Ocultar';
    if (_obscure) {
      tooltip = 'Mostrar';
    }
    return tooltip;
  }

  /// Devuelve el icono del botón de visibilidad de contraseña
  IconData _getPasswordVisibilityIcon() {
    IconData icon = Icons.visibility;
    if (_obscure) {
      icon = Icons.visibility_off;
    }
    return icon;
  }

  /// Devuelve el callback del botón de submit (null si está cargando)
  VoidCallback? _getSubmitButtonCallback() {
    VoidCallback? callback;
    if (!_isLoading) {
      callback = _submit;
    }
    return callback;
  }

  /// Devuelve el widget hijo del botón de submit (spinner o texto)
  Widget _getSubmitButtonChild() {
    Widget child = const Text('Entrar');
    if (_isLoading) {
      child = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return child;
  }

  Future<void> _submit() async {
    // Validar el formulario
    bool valid = false;
    if (_formKey.currentState != null) {
      valid = _formKey.currentState!.validate();
    }
    
    // Solo continuar si es válido y no está cargando
    if (valid && !_isLoading) {
      // Iniciar proceso de login
      final auth = context.read<AuthController>();
      setState(() => _isLoading = true);
      await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      
      // Verificar que el widget sigue montado
      if (mounted) {
        setState(() => _isLoading = false);

        // Verificar si hubo error
        final err = context.read<AuthController>().error;
        bool hasError = err.isNotEmpty;

        // Si no hay error, navegar a home
        if (!hasError) {
          // Verificar de nuevo que el widget sigue montado antes de navegar
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.home,
              (route) => false,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Accede a tu cuenta para guardar reseñas y listas.',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.70),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                //Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email', style: text.titleMedium),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    hintText: 'tucorreo@ejemplo.com',
                  ),
                ),

                const SizedBox(height: 16),

                //Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Contraseña', style: text.titleMedium),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      tooltip: _getPasswordVisibilityTooltip(),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _getPasswordVisibilityIcon(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                //Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recuperación: próximamente'),
                        ),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Mostrar error si existe
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    if (authController.error.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authController.error,
                                style: text.bodyMedium?.copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Login button
                FilledButton(
                  onPressed: _getSubmitButtonCallback(),
                  child: _getSubmitButtonChild(),
                ),

                const SizedBox(height: 16),

                // Register button
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(AppRouter.register),
                  child: const Text('Crear cuenta'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
