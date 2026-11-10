import 'package:flutter/material.dart';
import 'package:linkflutter/core/utils/responsive.dart';

/// Cadre responsive pour les maquettes pro (référence iPhone ~390 pt).
class ProDesignCanvas extends StatelessWidget {
  const ProDesignCanvas({
    required this.child,
    this.referenceWidth = 390,
    this.referenceHeight = 844,
    super.key,
  });

  static const defaultReferenceWidth = 390.0;
  static const defaultReferenceHeight = 844.0;

  final Widget child;
  final double referenceWidth;

  /// Si `null`, la hauteur suit le contenu (aperçu avec formulaire, etc.).
  final double? referenceHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final maxWidth = context.responsive<double>(
          mobile: parentWidth,
          tablet: 420,
          desktop: 480,
        );

        final targetWidth = parentWidth > maxWidth ? maxWidth : parentWidth;
        if (targetWidth <= 0) return child;

        final mediaHeight = referenceHeight ?? 2000.0;
        final framedChild = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(referenceWidth, mediaHeight),
            textScaler: TextScaler.noScaling,
          ),
          child: child,
        );

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: targetWidth,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: referenceHeight == null
                  ? SizedBox(
                      width: referenceWidth,
                      child: framedChild,
                    )
                  : SizedBox(
                      width: referenceWidth,
                      height: referenceHeight,
                      child: framedChild,
                    ),
            ),
          ),
        );
      },
    );
  }
}
