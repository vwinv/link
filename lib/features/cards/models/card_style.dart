import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

enum CardStyle {
  noir(
    label: 'Noir',
    background: Color(0xFF121212),
    accent: AppColors.bleu_primaire,
    previewForeground: Color(0xFF7A7A7A),
    lightTheme: false,
  ),
  bleu(
    label: 'Bleu',
    background: Color(0xFF0A6BFF),
    accent: Color(0xFF3D8BFF),
    previewForeground: AppColors.onPrimary,
    lightTheme: false,
  ),
  rouge(
    label: 'Rouge',
    background: Color(0xFFE84545),
    accent: Color(0xFFFF8A80),
    previewForeground: Color(0xFFFFE8E8),
    lightTheme: false,
  ),
  vert(
    label: 'Vert',
    background: Color.fromARGB(255, 58, 122, 81),
    accent: Color(0xFF2DBE8C),
    previewForeground: Color(0xFFDDF5EC),
    lightTheme: false,
  ),
  ambre(
    label: 'Ambre',
    background: Color(0xFFF0A830),
    accent: Color(0xFFFFB020),
    previewForeground: Color(0xFF5C3D0A),
    lightTheme: true,
  ),
  blanc(
    label: 'Blanc',
    background: Color(0xFFF3F3F5),
    accent: AppColors.bleu_primaire,
    previewForeground: Color(0xFF6B7280),
    lightTheme: true,
  );

  const CardStyle({
    required this.label,
    required this.background,
    required this.accent,
    required this.previewForeground,
    required this.lightTheme,
  });

  final String label;
  final Color background;
  final Color accent;
  final Color previewForeground;
  final bool lightTheme;

  static CardStyle fromKey(String? key) {
    return CardStyle.values.firstWhere(
      (style) => style.name == key,
      orElse: () => CardStyle.noir,
    );
  }
}
