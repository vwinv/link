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
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_guest_lead.dart';

/// Contenu de la carte - partagé entre l’aperçu plein écran et la grille.
class ProDesignBody extends StatelessWidget {
  const ProDesignBody({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    this.companyName = 'Mega SN',
    this.address,
    this.avatarUrl,
    this.logoUrl,
    this.showGuestLead = true,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String companyName;
  final String? address;
  final String? avatarUrl;
  final String? logoUrl;
  final bool showGuestLead;

  @override
  Widget build(BuildContext context) {
    final body = switch (template.layout) {
      ProDesignLayout.azurCentered => AzurCenteredDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
      ProDesignLayout.corailGradient => CorailGradientDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
      ProDesignLayout.blancLight => BlancLightDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
      ProDesignLayout.degradeNoir => DegradeNoirDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
      ProDesignLayout.bubble => BubbleDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
          showGuestLead: showGuestLead,
        ),
      ProDesignLayout.arc => ArcDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
          showGuestLead: showGuestLead,
        ),
      ProDesignLayout.nuit => NuitDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
      ProDesignLayout.or => OrDesign(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
      ProDesignLayout.legacy => LegacyProDesignPreview(
          template: template,
          fullName: fullName,
          initials: initials,
          subtitle: subtitle,
          companyName: companyName,
          address: address,
          compact: false,
          avatarUrl: avatarUrl,
          logoUrl: logoUrl,
        ),
    };

    // Bubble / Arc gèrent le formulaire dans leur propre body.
    if (!showGuestLead ||
        template.layout == ProDesignLayout.bubble ||
        template.layout == ProDesignLayout.arc) {
      return body;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        body,
        ProDesignGuestLeadPreview(template: template),
      ],
    );
  }
}
