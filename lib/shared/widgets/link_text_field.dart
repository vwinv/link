import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

OutlineInputBorder _fieldBorder({Color? color, double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(
      color: color ?? AppColors.border,
      width: width,
    ),
  );
}

class LinkTextField extends StatelessWidget {
  const LinkTextField({
    required this.label,
    required this.controller,
    super.key,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: AppFontWeight.semiBold,
            color: AppColors.textTertiaire,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: const TextStyle(
            fontSize: AppFontSize.md,
            fontWeight: AppFontWeight.medium,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textTertiaire,
              fontWeight: AppFontWeight.regular,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: _fieldBorder(),
            enabledBorder: _fieldBorder(),
            focusedBorder: _fieldBorder(
              color: AppColors.bleu_primaire,
              width: 1.5,
            ),
            disabledBorder: _fieldBorder(),
            errorBorder: _fieldBorder(color: AppColors.error),
            focusedErrorBorder: _fieldBorder(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
