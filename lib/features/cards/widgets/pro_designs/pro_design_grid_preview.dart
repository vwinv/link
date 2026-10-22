import 'package:flutter/material.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_grid_card.dart';

/// Aperçu grille miniature du rendu plein écran.
class ProDesignGridPreview extends StatelessWidget {
  const ProDesignGridPreview({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    required this.companyName,
    required this.onOpen,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String companyName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ProDesignGridCard(
      template: template,
      fullName: fullName,
      initials: initials,
      subtitle: subtitle,
      companyName: companyName,
      onOpen: onOpen,
    );
  }
}
