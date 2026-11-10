import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_layout.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';

/// Formulaire contact invité (aperçu), aligné sur les skins boutons du layout.
class ProDesignGuestLeadPreview extends StatelessWidget {
  const ProDesignGuestLeadPreview({
    required this.template,
    super.key,
  });

  final ProDesignTemplate template;

  @override
  Widget build(BuildContext context) {
    final skin = _GuestLeadSkin.forLayout(template.layout, template.accentColor);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        decoration: BoxDecoration(
          color: skin.panelBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: skin.panelBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Laissez moi votre contact',
              style: TextStyle(
                color: skin.text,
                fontSize: context.rs(16),
                fontWeight: AppFontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Un projet, une collaboration ? Laissez vos coordonnées.',
              style: TextStyle(
                color: skin.text.withValues(alpha: 0.72),
                fontSize: context.rs(13),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            _GuestField(hint: 'Ibrahima Fall', skin: skin),
            const SizedBox(height: 8),
            _GuestField(hint: 'ibrahima.fall@email.com', skin: skin),
            const SizedBox(height: 8),
            _GuestField(hint: '771234567', skin: skin),
            const SizedBox(height: 8),
            Container(
              height: AppSizes.buttonHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: skin.submitBg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                'Envoyer',
                style: TextStyle(
                  color: skin.submitText,
                  fontSize: context.rs(15),
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestField extends StatelessWidget {
  const _GuestField({
    required this.hint,
    required this.skin,
  });

  final String hint;
  final _GuestLeadSkin skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: skin.fieldBorder),
      ),
      child: Text(
        hint,
        style: TextStyle(
          color: skin.text.withValues(alpha: 0.28),
          fontSize: context.rs(15),
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}

class _GuestLeadSkin {
  const _GuestLeadSkin({
    required this.panelBg,
    required this.panelBorder,
    required this.text,
    required this.fieldBorder,
    required this.submitBg,
    required this.submitText,
  });

  final Color panelBg;
  final Color panelBorder;
  final Color text;
  final Color fieldBorder;
  final Color submitBg;
  final Color submitText;

  static _GuestLeadSkin forLayout(ProDesignLayout layout, Color accent) {
    switch (layout) {
      case ProDesignLayout.bubble:
      case ProDesignLayout.arc:
        return _GuestLeadSkin(
          panelBg: const Color(0xFFF2F2F7),
          panelBorder: Colors.transparent,
          text: AppColors.textPrimary,
          fieldBorder: accent.withValues(alpha: 0.35),
          submitBg: accent,
          submitText: AppColors.onPrimary,
        );
      case ProDesignLayout.blancLight:
        return _GuestLeadSkin(
          panelBg: AppColors.onPrimary,
          panelBorder: accent.withValues(alpha: 0.35),
          text: accent,
          fieldBorder: accent.withValues(alpha: 0.35),
          submitBg: accent,
          submitText: AppColors.onPrimary,
        );
      case ProDesignLayout.nuit:
        return _GuestLeadSkin(
          panelBg: Colors.transparent,
          panelBorder: AppColors.onPrimary.withValues(alpha: 0.55),
          text: AppColors.onPrimary,
          fieldBorder: AppColors.onPrimary.withValues(alpha: 0.4),
          submitBg: AppColors.onPrimary,
          submitText: accent,
        );
      case ProDesignLayout.or:
        return _GuestLeadSkin(
          panelBg: Colors.transparent,
          panelBorder: AppColors.onPrimary.withValues(alpha: 0.35),
          text: AppColors.onPrimary,
          fieldBorder: AppColors.onPrimary.withValues(alpha: 0.35),
          submitBg: accent,
          submitText: const Color(0xFF1A1A1A),
        );
      case ProDesignLayout.degradeNoir:
        return _GuestLeadSkin(
          panelBg: AppColors.onPrimary.withValues(alpha: 0.08),
          panelBorder: AppColors.onPrimary.withValues(alpha: 0.18),
          text: AppColors.onPrimary,
          fieldBorder: AppColors.onPrimary.withValues(alpha: 0.35),
          submitBg: AppColors.onPrimary,
          submitText: AppColors.textPrimary,
        );
      case ProDesignLayout.corailGradient:
        return _GuestLeadSkin(
          panelBg: AppColors.onPrimary.withValues(alpha: 0.14),
          panelBorder: AppColors.onPrimary.withValues(alpha: 0.28),
          text: AppColors.onPrimary,
          fieldBorder: AppColors.onPrimary.withValues(alpha: 0.35),
          submitBg: AppColors.onPrimary,
          submitText: accent,
        );
      case ProDesignLayout.azurCentered:
      case ProDesignLayout.legacy:
        return _GuestLeadSkin(
          panelBg: AppColors.onPrimary,
          panelBorder: Colors.transparent,
          text: accent,
          fieldBorder: accent.withValues(alpha: 0.4),
          submitBg: AppColors.onPrimary,
          submitText: accent,
        );
    }
  }
}
