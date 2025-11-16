import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// Tema oscuro de CheckPoint.
/// Centraliza colores, tipografías y estilos de componentes para consistencia.
ThemeData checkpointTheme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );
  final scheme = baseScheme.copyWith(
    surface: AppColors.surface,
    outline: AppColors.stroke,
  );

  // Tipografías
  const textTheme = AppTypography.textTheme;

  // Botones
  final elevatedButtons = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: scheme.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
    ),
  );

  final filledButtons = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  final outlinedButtons = OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size.fromHeight(52)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      foregroundColor: WidgetStateProperty.all(AppColors.onBgTextWeak),
      side: WidgetStateProperty.resolveWith((states) {
        final base = BorderSide(color: AppColors.stroke);
        if (states.contains(WidgetState.pressed)) {
          return base.copyWith(width: 1.4, color: scheme.primary);
        }
        return base;
      }),
    ),
  );

  // Inputs (Login/Register)
  final inputs = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: const TextStyle(color: AppColors.hint),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.stroke),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error, width: 1.2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant),
    ),
  );

  // AppBar
  final appBar = AppBarTheme(
    backgroundColor: AppColors.bg,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: textTheme,
    appBarTheme: appBar,
    inputDecorationTheme: inputs,
    elevatedButtonTheme: elevatedButtons,
    filledButtonTheme: filledButtons,
    outlinedButtonTheme: outlinedButtons,
    dividerColor: AppColors.stroke,
    iconTheme: const IconThemeData(color: AppColors.onBgIcon),
    splashFactory: InkSparkle.splashFactory,
  );
}
