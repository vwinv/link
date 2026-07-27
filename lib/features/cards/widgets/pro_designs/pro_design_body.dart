import 'package:flutter/material.dart';
import 'package:linkflutter/features/cards/models/pro_design_layout.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/arc_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/azur_centered_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/blanc_light_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/bubble_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/corail_gradient_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/degrade_noir_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/legacy_pro_design_preview.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/nuit_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/or_design.dart';

/// Contenu de la carte — partagé entre l’aperçu plein écran et la grille.
class ProDesignBody extends StatelessWidget {
  const ProDesignBody({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    this.companyName = 'Mega SN',
    this.avatarUrl,
    this.logoUrl,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String companyName;
  final String? avatarUrl;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    switch (template.layout) {
      case ProDesignLayout.azurCentered:
        return AzurCenteredDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.corailGradient:
        return CorailGradientDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.blancLight:
        return BlancLightDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.degradeNoir:
        return DegradeNoirDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.bubble:
        return BubbleDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.arc:
        return ArcDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.nuit:
        return NuitDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.or:
        return OrDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
      case ProDesignLayout.legacy:
        return LegacyProDesignPreview(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          compact: false,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        );
    }
  }
}
