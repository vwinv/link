import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

/// Badge « Voir ma carte » posé au-dessus d’un aperçu de carte.
class CardPreviewBadge extends StatelessWidget {
  const CardPreviewBadge({
    required this.child,
    required this.onPreview,
    required this.label,
    this.dark = false,
    super.key,
  });

  final Widget child;
  final VoidCallback onPreview;
  final String label;
  final bool dark;

  /// Partie du bouton qui dépasse au-dessus de la carte.
  static const overhang = 28.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: overhang),
          child: child,
        ),
        Positioned(
          top: 0,
          right: 10,
          child: Material(
            color: dark ? Colors.black : Colors.white,
            elevation: 2,
            shadowColor: const Color(0x330C0D10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: BorderSide(
                color: dark ? Colors.black : AppColors.border,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: onPreview,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: dark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black,
                        fontSize: 13,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
