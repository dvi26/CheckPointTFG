import 'package:flutter/material.dart';
import 'package:checkpoint/app/router.dart';
import 'package:provider/provider.dart';
import 'package:checkpoint/features/auth/presentation/controllers/auth_controller.dart';

/// Pantalla de registro de usuario.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Limpiar error cuando el usuario empieza a escribir
    _nameCtrl.addListener(_onTextChanged);
    _emailCtrl.addListener(_onTextChanged);
    _passCtrl.addListener(_onTextChanged);
    _confirmCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      context.read<AuthController>().clearError();
    }
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onTextChanged);
    _emailCtrl.removeListener(_onTextChanged);
    _passCtrl.removeListener(_onTextChanged);
    _confirmCtrl.removeListener(_onTextChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? input) {
    String? msg;
    
    String value = '';
    if (input != null) {
      value = input.trim();
    }
    
    if (value.isEmpty) {
      msg = 'Introduce tu nombre o alias.';
    } else if (value.length < 2) {
      msg = 'Debe tener al menos 2 caracteres.';
    }
    return msg;
  }

  String? _validateEmail(String? input) {
    String? msg;
    
    String value = '';
    if (input != null) {
      value = input.trim();
    }
    
    if (value.isEmpty) {
      msg = 'Introduce tu email.';
    } else if (!value.contains('@') || !value.contains('.')) {
      msg = 'Email no válido.';
    }
    return msg;
  }

  String? _validatePassword(String? input) {
    String? msg;
    
    String value = '';
    if (input != null) {
      value = input;
    }
    
    if (value.isEmpty) {
      msg = 'Introduce tu contraseña.';
    } else if (value.length < 6) {
      msg = 'Mínimo 6 caracteres.';
    }
    return msg;
  }

  String? _validateConfirm(String? input) {
    String? msg;
    
    String value = '';
    if (input != null) {
      value = input;
    }
    
    if (value.isEmpty) {
      msg = 'Repite la contraseña.';
    } else if (value != _passCtrl.text) {
      msg = 'Las contraseñas no coinciden.';
    }
    return msg;
  }

  /// Devuelve el tooltip del botón de visibilidad de contraseña
  String _getPasswordVisibilityTooltip() {
    String tooltip = 'Ocultar';
    if (_obscurePass) {
      tooltip = 'Mostrar';
    }
    return tooltip;
  }

  /// Devuelve el icono del botón de visibilidad de contraseña
  IconData _getPasswordVisibilityIcon() {
    IconData icon = Icons.visibility;
    if (_obscurePass) {
      icon = Icons.visibility_off;
    }
    return icon;
  }

  /// Devuelve el tooltip del botón de visibilidad de confirmación
  String _getConfirmVisibilityTooltip() {
    String tooltip = 'Ocultar';
    if (_obscureConfirm) {
      tooltip = 'Mostrar';
    }
    return tooltip;
  }

  /// Devuelve el icono del botón de visibilidad de confirmación
  IconData _getConfirmVisibilityIcon() {
    IconData icon = Icons.visibility;
    if (_obscureConfirm) {
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
    Widget child = const Text('Crear cuenta');
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

    // Verificar si los términos fueron aceptados
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos.')),
      );
    }

    // Solo continuar si es válido, aceptó términos y no está cargando
    if (valid && _acceptTerms && !_isLoading) {
      // Iniciar proceso de registro
      final auth = context.read<AuthController>();
      setState(() => _isLoading = true);
      await auth.signUp(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      // Verificar que el widget sigue montado
      if (mounted) {
        setState(() => _isLoading = false);

        final err = context.read<AuthController>().error;
        bool hasError = err.isNotEmpty;

        // Si no hay error, mostrar mensaje y navegar
        if (!hasError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cuenta creada correctamente')),
            );
            
            // Navegar a home y limpiar stack
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
  }

  @override  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
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
                    'Regístrate para guardar valoraciones y listas.',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.70),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nombre o alias', style: text.titleMedium),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                  decoration: const InputDecoration(
                    hintText: 'Ej. PlayerOne',
                  ),
                ),

                const SizedBox(height: 16),

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

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Contraseña', style: text.titleMedium),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      tooltip: _getPasswordVisibilityTooltip(),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      icon: Icon(
                        _getPasswordVisibilityIcon(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirmar contraseña', style: text.titleMedium),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validateConfirm,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      tooltip: _getConfirmVisibilityTooltip(),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _getConfirmVisibilityIcon(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (v) {
                        bool newValue = false;
                        if (v != null) {
                          newValue = v;
                        }
                        setState(() => _acceptTerms = newValue);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Acepto los términos y la política de privacidad.',
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.80),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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

                FilledButton(
                  onPressed: _getSubmitButtonCallback(),
                  child: _getSubmitButtonChild(),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(AppRouter.login),
                  child: const Text('Ya tengo cuenta'),
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
