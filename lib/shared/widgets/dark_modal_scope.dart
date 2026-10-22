import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

/// Enveloppe les écrans modaux sombres (partage, wallet, personnaliser).
class DarkModalScope extends StatelessWidget {
  const DarkModalScope({required this.child, super.key});

  static const surface = Color(0xFF0C0D10);

  final Widget child;

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        onSurface: AppColors.onPrimary,
        primary: AppColors.bleu_primaire,
        onPrimary: AppColors.onPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: surface,
        ),
        child: ColoredBox(
          color: surface,
          child: child,
        ),
      ),
    );
  }
}
