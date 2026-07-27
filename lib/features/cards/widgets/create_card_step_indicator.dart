import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

class CreateCardStepIndicator extends StatelessWidget {
  const CreateCardStepIndicator({
    required this.currentStep,
    required this.stepLabel,
    super.key,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < totalSteps - 1 ? AppSpacing.sm : 0,
                ),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.bleu_primaire
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Étape $currentStep/$totalSteps · $stepLabel',
          style: const TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: AppFontWeight.semiBold,
            color: AppColors.bleu_primaire,
          ),
        ),
      ],
    );
  }
}
