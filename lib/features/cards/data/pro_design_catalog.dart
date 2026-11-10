import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/cards/models/card_theme_settings.dart';
import 'package:linkflutter/features/cards/models/pro_design_layout.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';

abstract final class ProDesignCatalog {
  /// Fallback interne (plus proposé dans la grille premium).
  static const _uniFallback = ProDesignTemplate(
    id: 'uni',
    name: 'Uni',
    background: Color(0xFF0A6BFF),
    layout: ProDesignLayout.azurCentered,
  );

  /// Grille = aperçu miniature de `ProDesignBody` (même rendu que « Ouvrir »).
  static const templates = [
    ProDesignTemplate(
      id: 'degrade',
      name: 'Degrade',
      background: Color(0xFFFF8036),
      gradientEnd: Color(0xFFFF4545),
      accent: Color(0xFFFF8036),
      layout: ProDesignLayout.corailGradient,
    ),
    ProDesignTemplate(
      id: 'blanc',
      name: 'Blanc',
      background: AppColors.background,
      accent: Color(0xFF0A6BFF),
      layout: ProDesignLayout.blancLight,
    ),
    ProDesignTemplate(
      id: 'degrade-noir',
      name: 'Degrade noir',
      background: Color(0xFF0A4D35),
      gradientEnd: ProDesignTemplate.degradeNoirBlack,
      accent: Color(0xFF0A4D35),
      layout: ProDesignLayout.degradeNoir,
    ),
    ProDesignTemplate(
      id: 'bubble',
      name: 'Bubble',
      background: AppColors.background,
      accent: Color(0xFF0A6BFF),
      layout: ProDesignLayout.bubble,
    ),
    ProDesignTemplate(
      id: 'arc',
      name: 'Arc',
      background: Color(0xFF5E5CE6),
      accent: Color(0xFF5E5CE6),
      layout: ProDesignLayout.arc,
    ),
    ProDesignTemplate(
      id: 'nuit',
      name: 'Nuit',
      background: Color(0xFF0B1A38),
      accent: Color(0xFF0B1A38),
      layout: ProDesignLayout.nuit,
    ),
    ProDesignTemplate(
      id: 'or',
      name: 'Or',
      background: ProDesignTemplate.orDefaultBackground,
      accent: ProDesignTemplate.orDefaultAccent,
      layout: ProDesignLayout.or,
    ),
  ];

  static const _legacyIds = {
    'azur': 'uni',
    'coral': 'degrade',
  };

  static ProDesignTemplate? byId(String? id) {
    if (id == null) return null;
    final resolvedId = _legacyIds[id] ?? id;
    if (resolvedId == _uniFallback.id) return _uniFallback;
    for (final template in templates) {
      if (template.id == resolvedId) return template;
    }
    return null;
  }

  /// Même logique que l’écran designs / la carte publique.
  static ProDesignTemplate? resolveTemplate(CardThemeSettings theme) {
    final base = byId(theme.proDesignId);
    if (base == null) return null;
    if (!theme.useCompanyColors) return base;

    final brandColor = theme.brandColorValue;
    if (brandColor == null) return base;

    return _applyBrandColor(base, brandColor);
  }

  static List<ProDesignTemplate> withBrandColor(Color color) {
    return templates.map((template) => _applyBrandColor(template, color)).toList();
  }

  static ProDesignTemplate _applyBrandColor(
    ProDesignTemplate template,
    Color color,
  ) {
    switch (template.layout) {
      case ProDesignLayout.azurCentered:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: color,
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.corailGradient:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: color,
          layout: template.layout,
          accent: color,
          brandColor: color,
          gradientEnd: Color.lerp(color, const Color(0xFF1A1A1A), 0.22)!,
        );
      case ProDesignLayout.blancLight:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: AppColors.background,
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.degradeNoir:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: color,
          gradientEnd: ProDesignTemplate.degradeNoirBlack,
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.bubble:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: AppColors.background,
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.arc:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: color,
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.nuit:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: color,
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.or:
        return ProDesignTemplate(
          id: template.id,
          name: template.name,
          background: ProDesignTemplate.orDarkBackground(color),
          layout: template.layout,
          accent: color,
          brandColor: color,
        );
      case ProDesignLayout.legacy:
        return template;
    }
  }
}
