import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

class CreateCardAvatarPicker extends StatelessWidget {
  const CreateCardAvatarPicker({
    required this.initials,
    super.key,
    this.imageFilePath,
    this.imageUrl,
    this.onAddPressed,
    this.onRemove,
    this.removeLabel,
  });

  final String initials;
  final String? imageFilePath;
  final String? imageUrl;
  final VoidCallback? onAddPressed;
  final VoidCallback? onRemove;
  final String? removeLabel;

  bool get _hasImage {
    if (imageFilePath != null && imageFilePath!.isNotEmpty) return true;
    final url = imageUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Container(
                  width: 112,
                  height: 112,
                  color: AppColors.bleu_primaire,
                  alignment: Alignment.center,
                  child: _buildAvatarContent(),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onAddPressed,
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.bleu_primaire,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.onPrimary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _hasImage ? Icons.edit_rounded : Icons.add_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onRemove != null && _hasImage) ...[
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: onRemove,
            child: Text(
              removeLabel ?? 'Supprimer la photo',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: AppFontWeight.medium,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (imageFilePath != null && imageFilePath!.isNotEmpty) {
      return Image.file(
        File(imageFilePath!),
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsText(),
      );
    }

    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsText(),
      );
    }

    return _initialsText();
  }

  Widget _initialsText() {
    return Text(
      initials,
      style: const TextStyle(
        color: AppColors.onPrimary,
        fontSize: AppFontSize.xxl,
        fontWeight: AppFontWeight.bold,
      ),
    );
  }
}
