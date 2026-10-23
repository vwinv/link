import 'package:flutter/material.dart';
import 'package:linkflutter/l10n/app_localizations.dart';

class PortfolioLayoutOption {
  const PortfolioLayoutOption({
    required this.id,
    required this.name,
    required this.hint,
  });

  final String id;
  final String Function(AppLocalizations l10n) name;
  final String Function(AppLocalizations l10n) hint;
}

class PortfolioColorOption {
  const PortfolioColorOption({
    required this.id,
    required this.name,
    required this.swatch,
    this.swatchEnd,
    this.barStart,
    this.barEnd,
    this.gallery,
  });

  final String id;
  final String Function(AppLocalizations l10n) name;
  final Color swatch;
  final Color? swatchEnd;
  final Color? barStart;
  final Color? barEnd;
  final List<Color>? gallery;

  Color get accent => barStart ?? swatch;

  Color get accentEnd => barEnd ?? swatchEnd ?? accent;

  Gradient? get swatchGradient {
    final end = swatchEnd;
    if (end == null) return null;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [swatch, end],
    );
  }

  bool get isLight {
    final sample = swatchEnd == null
        ? swatch
        : Color.lerp(swatch, swatchEnd!, 0.5)!;
    return sample.computeLuminance() > 0.55;
  }

  List<Color> get galleryBlocks =>
      gallery ??
      [
        accent,
        Color.lerp(accent, Colors.white, 0.4)!,
        accentEnd,
      ];
}

abstract final class PortfolioStyleCatalog {
  static final layouts = <PortfolioLayoutOption>[
    PortfolioLayoutOption(
      id: 'classique',
      name: _classique,
      hint: _classiqueHint,
    ),
    PortfolioLayoutOption(
      id: 'couverture',
      name: _couverture,
      hint: _couvertureHint,
    ),
    PortfolioLayoutOption(
      id: 'editorial',
      name: _editorial,
      hint: _editorialHint,
    ),
    PortfolioLayoutOption(
      id: 'galerie',
      name: _galerie,
      hint: _galerieHint,
    ),
    PortfolioLayoutOption(
      id: 'minimal',
      name: _minimal,
      hint: _minimalHint,
    ),
    PortfolioLayoutOption(
      id: 'bento',
      name: _bento,
      hint: _bentoHint,
    ),
    PortfolioLayoutOption(
      id: 'portrait',
      name: _portrait,
      hint: _portraitHint,
    ),
    PortfolioLayoutOption(
      id: 'cartes',
      name: _cartes,
      hint: _cartesHint,
    ),
  ];

  static final colors = <PortfolioColorOption>[
    PortfolioColorOption(
      id: 'noir',
      name: _noir,
      swatch: Color(0xFF111111),
      barStart: Color(0xFFD6A84A),
    ),
    PortfolioColorOption(
      id: 'ivoire',
      name: _ivoire,
      swatch: Color(0xFFF3EFE6),
      barStart: Color(0xFFB45428),
    ),
    PortfolioColorOption(
      id: 'foret',
      name: _foret,
      swatch: Color(0xFF0C4630),
      barStart: Color(0xFFF3E6C4),
    ),
    PortfolioColorOption(
      id: 'corail',
      name: _corail,
      swatch: Color(0xFFFF8A5C),
      swatchEnd: Color(0xFFFF4B86),
      barStart: Color(0xFFFFFFFF),
    ),
    PortfolioColorOption(
      id: 'bleu',
      name: _bleu,
      swatch: Color(0xFF2F6BFF),
      barStart: Color(0xFFFFFFFF),
    ),
    PortfolioColorOption(
      id: 'terre',
      name: _terre,
      swatch: Color(0xFFC2410E),
      swatchEnd: Color(0xFF7F2B0F),
      barStart: Color(0xFFFC874D),
    ),
    PortfolioColorOption(
      id: 'lagon',
      name: _lagon,
      swatch: Color(0xFF126E92),
      swatchEnd: Color(0xFF2BB8C9),
      barStart: Color(0xFF7EEDD6),
    ),
    PortfolioColorOption(
      id: 'neon',
      name: _neon,
      swatch: Color(0xFF3EC8FF),
      swatchEnd: Color(0xFF8B6CFF),
      barStart: Color(0xFF3EC8FF),
      barEnd: Color(0xFF8B6CFF),
      gallery: [Color(0xFF6B7CFF), Color(0xFFF3A58A), Color(0xFF3DCFC8)],
    ),
    PortfolioColorOption(
      id: 'sable',
      name: _sable,
      swatch: Color(0xFFE8E3DA),
      barStart: Color(0xFF1A1A1A),
    ),
    PortfolioColorOption(
      id: 'minuit',
      name: _minuit,
      swatch: Color(0xFF10182C),
      swatchEnd: Color(0xFF2A3E5C),
      barStart: Color(0xFFFFFFFF),
    ),
    PortfolioColorOption(
      id: 'soleil',
      name: _soleil,
      swatch: Color(0xFFFFE14A),
      barStart: Color(0xFF111111),
    ),
    PortfolioColorOption(
      id: 'lilas',
      name: _lilas,
      swatch: Color(0xFFF5C8DF),
      swatchEnd: Color(0xFFC9A6F0),
      barStart: Color(0xFF2A163E),
    ),
  ];

  static PortfolioLayoutOption layoutById(String id) {
    return layouts.firstWhere(
      (layout) => layout.id == id,
      orElse: () => layouts.first,
    );
  }

  static PortfolioColorOption colorById(String id) {
    return colors.firstWhere(
      (color) => color.id == id,
      orElse: () => colors.firstWhere((color) => color.id == 'neon'),
    );
  }

  static String _classique(AppLocalizations l10n) => l10n.portfolioLayoutClassique;
  static String _classiqueHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutClassiqueHint;
  static String _couverture(AppLocalizations l10n) =>
      l10n.portfolioLayoutCouverture;
  static String _couvertureHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutCouvertureHint;
  static String _editorial(AppLocalizations l10n) => l10n.portfolioLayoutEditorial;
  static String _editorialHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutEditorialHint;
  static String _galerie(AppLocalizations l10n) => l10n.portfolioLayoutGalerie;
  static String _galerieHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutGalerieHint;
  static String _minimal(AppLocalizations l10n) => l10n.portfolioLayoutMinimal;
  static String _minimalHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutMinimalHint;
  static String _bento(AppLocalizations l10n) => l10n.portfolioLayoutBento;
  static String _bentoHint(AppLocalizations l10n) => l10n.portfolioLayoutBentoHint;
  static String _portrait(AppLocalizations l10n) => l10n.portfolioLayoutPortrait;
  static String _portraitHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutPortraitHint;
  static String _cartes(AppLocalizations l10n) => l10n.portfolioLayoutCartes;
  static String _cartesHint(AppLocalizations l10n) =>
      l10n.portfolioLayoutCartesHint;

  static String _bleu(AppLocalizations l10n) => l10n.portfolioColorBleu;
  static String _ivoire(AppLocalizations l10n) => l10n.portfolioColorIvoire;
  static String _noir(AppLocalizations l10n) => l10n.portfolioColorNoir;
  static String _foret(AppLocalizations l10n) => l10n.portfolioColorForet;
  static String _neon(AppLocalizations l10n) => l10n.portfolioColorNeon;
  static String _corail(AppLocalizations l10n) => l10n.portfolioColorCorail;
  static String _lagon(AppLocalizations l10n) => l10n.portfolioColorLagon;
  static String _lilas(AppLocalizations l10n) => l10n.portfolioColorLilas;
  static String _terre(AppLocalizations l10n) => l10n.portfolioColorTerre;
  static String _sable(AppLocalizations l10n) => l10n.portfolioColorSable;
  static String _soleil(AppLocalizations l10n) => l10n.portfolioColorSoleil;
  static String _minuit(AppLocalizations l10n) => l10n.portfolioColorMinuit;
}
