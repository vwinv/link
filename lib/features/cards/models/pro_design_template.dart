import 'package:flutter/material.dart';
import 'package:linkflutter/features/cards/models/pro_design_layout.dart';

class ProDesignTemplate {
  const ProDesignTemplate({
    required this.id,
    required this.name,
    required this.background,
    required this.layout,
    this.accent,
    this.gradientEnd,
    this.brandColor,
  });

  final String id;
  final String name;
  final Color background;
  final ProDesignLayout layout;
  final Color? accent;
  final Color? gradientEnd;
  final Color? brandColor;

  bool get isBranded => brandColor != null;

  bool get usesLightSurface =>
      layout == ProDesignLayout.blancLight ||
      layout == ProDesignLayout.bubble ||
      layout == ProDesignLayout.arc;

  bool get usesBubbleHeader => layout == ProDesignLayout.bubble;

  bool get usesArcLayout => layout == ProDesignLayout.arc;

  bool get usesColoredChrome =>
      layout == ProDesignLayout.bubble || layout == ProDesignLayout.arc;

  static const degradeNoirBlack = Color(0xFF000000);

  static const orDefaultAccent = Color(0xFFD4A843);

  static const orDefaultBackground = Color(0xFF141108);

  /// Fond Or : teinte très foncée de la couleur de marque.
  static Color orDarkBackground(Color color) {
    return Color.lerp(color, degradeNoirBlack, 0.9)!;
  }

  Color get themeColor => accent ?? background;

  Color get accentColor => brandColor ?? accent ?? background;

  Color get displayColor =>
      layout == ProDesignLayout.degradeNoir ? degradeNoirBlack : (gradientEnd ?? background);

  BoxDecoration get backgroundDecoration {
    if (layout == ProDesignLayout.degradeNoir) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, degradeNoirBlack],
          stops: const [0.0, 0.45],
        ),
      );
    }
    if (gradientEnd != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, gradientEnd!],
        ),
      );
    }
    return BoxDecoration(color: background);
  }
}
