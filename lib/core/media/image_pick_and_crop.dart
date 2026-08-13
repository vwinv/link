import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

enum ImageCropKind {
  /// Photo de profil : cadre circulaire 1:1.
  avatar,

  /// Logo entreprise / équipe : cadre carré 1:1.
  logo,
}

/// Sélection galerie puis écran de rognage.
class ImagePickAndCrop {
  ImagePickAndCrop({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickAndCrop({
    required ImageCropKind kind,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 95,
      requestFullMetadata: false,
    );
    if (picked == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      maxWidth: 1024,
      maxHeight: 1024,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: _titleFor(kind),
          toolbarColor: AppColors.bleu_primaire,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.bleu_primaire,
          statusBarLight: false,
          backgroundColor: Colors.black,
          cropStyle: kind == ImageCropKind.avatar
              ? CropStyle.circle
              : CropStyle.rectangle,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: _titleFor(kind),
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
          aspectRatioPickerButtonHidden: true,
          cropStyle: kind == ImageCropKind.avatar
              ? CropStyle.circle
              : CropStyle.rectangle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
      ],
    );

    return cropped?.path;
  }

  String _titleFor(ImageCropKind kind) {
    return switch (kind) {
      ImageCropKind.avatar => 'Rogner la photo',
      ImageCropKind.logo => 'Rogner le logo',
    };
  }
}
