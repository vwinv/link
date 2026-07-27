import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:provider/provider.dart';

class CreateCardHeader extends StatelessWidget {
  const CreateCardHeader({super.key});

  static const _sideSlotWidth = 96.0;

  void _handleBackFromWorkspace(BuildContext context) {
    final createCard = context.read<CreateCardProvider>();

    switch (createCard.currentStep) {
      case 1:
        createCard.reset();
        context.go(RoutePaths.home);
      case 2:
        createCard.goToStep(1);
        context.go(RoutePaths.createCard);
      default:
        createCard.goToStep(2);
        context.go(RoutePaths.createCardStep2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createCard = context.watch<CreateCardProvider>();
    final showBack =
        createCard.fromExistingWorkspace || createCard.currentStep > 1;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: _sideSlotWidth,
            child: showBack
                ? LinkBackButton(
                    onPressed: createCard.fromExistingWorkspace
                        ? () => _handleBackFromWorkspace(context)
                        : null,
                  )
                : null,
          ),
          Expanded(
            child: Text(
              l10n.createCardHeaderTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppFontSize.lg,
                fontWeight: AppFontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: _sideSlotWidth),
        ],
      ),
    );
  }
}
