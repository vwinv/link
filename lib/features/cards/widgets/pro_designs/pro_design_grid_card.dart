import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_layout.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_body.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_canvas.dart';

/// Tuile grille : aperçu miniature du même rendu que « Ouvrir ».
class ProDesignGridCard extends StatelessWidget {
  const ProDesignGridCard({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    required this.companyName,
    required this.onOpen,
    this.avatarUrl,
    this.logoUrl,
    this.isActiveDesign = false,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String companyName;
  final String? avatarUrl;
  final String? logoUrl;
  final VoidCallback onOpen;
  final bool isActiveDesign;

  @override
  Widget build(BuildContext context) {
    final isEdgeToEdge = template.layout == ProDesignLayout.bubble ||
        template.layout == ProDesignLayout.arc;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: isActiveDesign
            ? Border.all(color: AppColors.bleu_primaire, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: context.rs(16),
            offset: Offset(0, context.rs(6)),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: template.backgroundDecoration,
              child: ProDesignCanvas(
                child: DecoratedBox(
                  decoration: template.backgroundDecoration,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isEdgeToEdge ? 0 : AppSpacing.screenHorizontal,
                      isEdgeToEdge ? 0 : AppSpacing.lg,
                      isEdgeToEdge ? 0 : AppSpacing.screenHorizontal,
                      AppSpacing.xl,
                    ),
                    child: ProDesignBody(
                      template: template,
                      fullName: fullName,
                      initials: initials,
                      subtitle: subtitle,
                      companyName: companyName,
                      avatarUrl: avatarUrl,
                      logoUrl: logoUrl,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ColoredBox(
            color: AppColors.surface,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rs(12),
                vertical: context.rs(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(14),
                        fontWeight: AppFontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onOpen,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ouvrir',
                          style: TextStyle(
                            color: AppColors.bleu_primaire,
                            fontSize: context.rs(13),
                            fontWeight: AppFontWeight.medium,
                            height: 1.1,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.bleu_primaire,
                          size: context.rs(18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
