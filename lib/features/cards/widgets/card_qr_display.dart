import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardQrDisplay extends StatelessWidget {
  const CardQrDisplay({
    required this.data,
    super.key,
    this.size = 56,
    this.padding = 6,
    this.dotColor = AppColors.bleu_primaire,
  });

  final String data;
  final double size;
  final double padding;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final qrSize = size - (padding * 2);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: QrImageView(
        data: data,
        size: qrSize,
        backgroundColor: AppColors.onPrimary,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: dotColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: dotColor,
        ),
      ),
    );
  }
}
