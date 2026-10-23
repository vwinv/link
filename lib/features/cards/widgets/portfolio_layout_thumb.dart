import 'package:flutter/material.dart';
import 'package:linkflutter/features/cards/data/portfolio_style_catalog.dart';

/// Vignette schématique d’un modèle, teintée par la couleur choisie.
class PortfolioLayoutThumb extends StatelessWidget {
  const PortfolioLayoutThumb({
    required this.layoutId,
    required this.color,
    this.avatarUrl,
    super.key,
  });

  final String layoutId;
  final PortfolioColorOption color;
  final String? avatarUrl;

  static const _galleryTiles = [
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6B8AFE), Color(0xFF4D69F8)],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFC1AD), Color(0xFFF58C6C)],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF27C1C3), Color(0xFF2982E0)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ink = _ThumbInk.of(color);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ink.wash == null ? ink.canvas : null,
          gradient: ink.wash,
        ),
        child: switch (layoutId) {
          'couverture' => _cover(ink),
          'editorial' => _editorial(ink),
          'galerie' => _galleryLayout(ink),
          'minimal' => _minimal(ink),
          'bento' => _bento(ink),
          'portrait' => _portrait(ink),
          'cartes' => _cards(ink),
          _ => _classic(ink),
        },
      ),
    );
  }

  Widget _classic(_ThumbInk ink) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          Expanded(child: _roundFace(ink)),
          const SizedBox(height: 8),
          _pill(ink, 0.72, align: Alignment.center),
          const SizedBox(height: 5),
          _pill(ink, 0.46, height: 5, align: Alignment.center),
          const SizedBox(height: 5),
          _pill(ink, 0.58, accent: true, align: Alignment.center),
        ],
      ),
    );
  }

  Widget _cover(_ThumbInk ink) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _face(ink, align: Alignment.topCenter),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _pill(ink, 1, height: 7),
        ),
      ],
    );
  }

  Widget _editorial(_ThumbInk ink) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pill(ink, 0.92),
                const SizedBox(height: 6),
                _pill(ink, 0.62, accent: true),
                const SizedBox(height: 8),
                _line(ink, 0.84),
                const SizedBox(height: 4),
                _line(ink, 0.7),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            height: 58,
            child: _face(ink, radius: 8),
          ),
        ],
      ),
    );
  }

  Widget _galleryLayout(_ThumbInk ink) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const designW = 200.0;
        const designH = 128.0;
        final byWidth = constraints.maxWidth / designW;
        final byHeight = constraints.maxHeight / designH;
        final scale = byWidth < byHeight ? byWidth : byHeight;
        double s(double value) => value * scale;
        final tileW = s(53);
        final tileH = s(70);
        return Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: s(designW),
            height: s(designH),
            child: Stack(
              children: [
                Positioned(
                  left: s(12),
                  top: s(14),
                  width: s(18),
                  height: s(18),
                  child: _face(ink, circle: true, bordered: false),
                ),
                Positioned(
                  left: s(38),
                  top: s(20),
                  width: s(52),
                  height: s(5),
                  child: DecoratedBox(decoration: ink.inkDecoration),
                ),
                for (var i = 0; i < _galleryTiles.length; i++)
                  Positioned(
                    left: s(12) + i * (tileW + s(8)),
                    top: s(46),
                    width: tileW,
                    height: tileH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _galleryTiles[i],
                        borderRadius: BorderRadius.circular(s(14)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _minimal(_ThumbInk ink) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        children: [
          Expanded(child: _roundFace(ink)),
          const SizedBox(height: 8),
          _pill(ink, 0.7, align: Alignment.center),
          const SizedBox(height: 6),
          _pill(ink, 0.42, accent: true, align: Alignment.center),
        ],
      ),
    );
  }

  Widget _bento(_ThumbInk ink) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(flex: 5, child: _face(ink, radius: 10)),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: _block(ink)),
                const SizedBox(height: 8),
                _pill(ink, 1, height: 6),
                const SizedBox(height: 5),
                _pill(ink, 0.72, height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _portrait(_ThumbInk ink) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(flex: 4, child: _face(ink, radius: 10)),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pill(ink, 1),
                const SizedBox(height: 6),
                _pill(ink, 0.7, accent: true),
                const SizedBox(height: 6),
                _line(ink, 0.85),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cards(_ThumbInk ink) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 16, height: 16, child: _face(ink, circle: true)),
              const SizedBox(width: 8),
              Expanded(child: _pill(ink, 0.7)),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 5),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _roundFace(_ThumbInk ink) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: _face(ink, circle: true),
          ),
        );
      },
    );
  }

  Widget _face(
    _ThumbInk ink, {
    bool circle = false,
    double radius = 12,
    Alignment align = Alignment.center,
    bool bordered = true,
  }) {
    final url = avatarUrl?.trim();
    final shape = circle ? BoxShape.circle : BoxShape.rectangle;
    final photo = url == null || url.isEmpty
        ? ColoredBox(
            color: ink.ink.withValues(alpha: 0.16),
            child: Icon(
              Icons.person,
              color: ink.ink.withValues(alpha: 0.85),
            ),
          )
        : Image.network(
            url,
            fit: BoxFit.cover,
            alignment: align,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => ColoredBox(
              color: ink.ink.withValues(alpha: 0.16),
              child: Icon(
                Icons.person,
                color: ink.ink.withValues(alpha: 0.85),
              ),
            ),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        border: bordered
            ? Border.all(color: ink.ink.withValues(alpha: 0.28))
            : null,
      ),
      child: ClipRRect(
        borderRadius: circle
            ? BorderRadius.circular(999)
            : BorderRadius.circular(radius),
        child: SizedBox.expand(child: photo),
      ),
    );
  }

  Widget _pill(
    _ThumbInk ink,
    double width, {
    double height = 6,
    bool accent = false,
    Alignment align = Alignment.centerLeft,
  }) {
    return Align(
      alignment: align,
      child: FractionallySizedBox(
        widthFactor: width,
        child: Container(
          height: height,
          decoration: accent ? ink.accentDecoration : ink.inkDecoration,
        ),
      ),
    );
  }

  Widget _line(_ThumbInk ink, double width) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: width,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: ink.ink.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }

  Widget _block(_ThumbInk ink) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ink.accentEnd == null ? ink.accent : null,
        gradient: ink.accentEnd == null
            ? null
            : LinearGradient(colors: [ink.accent, ink.accentEnd!]),
      ),
    );
  }
}

class _ThumbInk {
  const _ThumbInk({
    required this.canvas,
    required this.ink,
    required this.accent,
    this.canvasEnd,
    this.accentEnd,
  });

  final Color canvas;
  final Color? canvasEnd;
  final Color ink;
  final Color accent;
  final Color? accentEnd;

  LinearGradient? get wash => canvasEnd == null
      ? null
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [canvas, canvasEnd!],
        );

  BoxDecoration get inkDecoration => BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(99),
      );

  BoxDecoration get accentDecoration => BoxDecoration(
        color: accentEnd == null ? accent : null,
        gradient: accentEnd == null
            ? null
            : LinearGradient(colors: [accent, accentEnd!]),
        borderRadius: BorderRadius.circular(99),
      );

  static _ThumbInk of(PortfolioColorOption color) {
    return switch (color.id) {
      'noir' => const _ThumbInk(
          canvas: Color(0xFF111111),
          ink: Color(0xFFF4F4F4),
          accent: Color(0xFFD6A84A),
        ),
      'ivoire' => const _ThumbInk(
          canvas: Color(0xFFF3EFE6),
          ink: Color(0xFF1B1B1B),
          accent: Color(0xFFB45428),
        ),
      'foret' => const _ThumbInk(
          canvas: Color(0xFF0C4630),
          ink: Color(0xFFF3E6C4),
          accent: Color(0xFFF3E6C4),
        ),
      'corail' => const _ThumbInk(
          canvas: Color(0xFFFF8A5C),
          canvasEnd: Color(0xFFFF4B86),
          ink: Color(0xFFFFFFFF),
          accent: Color(0xFFFFFFFF),
        ),
      'bleu' => const _ThumbInk(
          canvas: Color(0xFF2F6BFF),
          ink: Color(0xFFFFFFFF),
          accent: Color(0xFFFFFFFF),
        ),
      'terre' => const _ThumbInk(
          canvas: Color(0xFFC2410E),
          canvasEnd: Color(0xFF7F2B0F),
          ink: Color(0xFFFFFFFF),
          accent: Color(0xFFFC874D),
        ),
      'lagon' => const _ThumbInk(
          canvas: Color(0xFF126E92),
          canvasEnd: Color(0xFF2BB8C9),
          ink: Color(0xFFFFFFFF),
          accent: Color(0xFF7EEDD6),
        ),
      'sable' => const _ThumbInk(
          canvas: Color(0xFFE8E3DA),
          ink: Color(0xFF1A1A1A),
          accent: Color(0xFF1A1A1A),
        ),
      'minuit' => const _ThumbInk(
          canvas: Color(0xFF10182C),
          canvasEnd: Color(0xFF2A3E5C),
          ink: Color(0xFFF4F4F4),
          accent: Color(0xFFF4F4F4),
        ),
      'soleil' => const _ThumbInk(
          canvas: Color(0xFFFFE14A),
          ink: Color(0xFF111111),
          accent: Color(0xFF111111),
        ),
      'lilas' => const _ThumbInk(
          canvas: Color(0xFFF5C8DF),
          canvasEnd: Color(0xFFC9A6F0),
          ink: Color(0xFF2A163E),
          accent: Color(0xFF2A163E),
        ),
      _ => const _ThumbInk(
          canvas: Color(0xFF0C1020),
          ink: Color(0xFFF4F4F4),
          accent: Color(0xFF3EC8FF),
          accentEnd: Color(0xFF8B6CFF),
        ),
    };
  }
}
