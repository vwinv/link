import 'package:flutter/material.dart';
import 'package:linkflutter/core/utils/responsive.dart';

/// Centre le contenu et limite sa largeur sur tablette / desktop.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.child,
    super.key,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.contentMaxWidth,
        ),
        child: Padding(
          padding: padding ?? context.screenPadding,
          child: child,
        ),
      ),
    );
  }
}
