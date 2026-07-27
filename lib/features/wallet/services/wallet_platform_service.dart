import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:apple_passkit/apple_passkit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/wallet/models/wallet_platform_type.dart';
import 'package:linkflutter/features/wallet/services/wallet_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPlatformService {
  WalletPlatformService(this._walletApi);

  final WalletApiService _walletApi;
  final ApplePassKit _applePassKit = ApplePassKit();

  WalletPlatformType? get currentPlatform {
    if (kIsWeb) return null;
    if (Platform.isIOS) return WalletPlatformType.apple;
    if (Platform.isAndroid) return WalletPlatformType.google;
    return null;
  }

  bool get isSupported => currentPlatform != null;

  Future<void> addCardToWallet(String cardId) async {
    final platform = currentPlatform;
    if (platform == null) {
      throw ApiException(
        'L’ajout au Wallet n’est pas disponible sur cette plateforme.',
      );
    }

    final result = await _walletApi.addCardToWallet(
      cardId: cardId,
      platform: platform,
    );

    switch (platform) {
      case WalletPlatformType.apple:
        await _addApplePass(result.passBase64);
      case WalletPlatformType.google:
        await _openGoogleWallet(result.saveUrl);
    }
  }

  Future<void> _addApplePass(String? passBase64) async {
    if (passBase64 == null || passBase64.isEmpty) {
      throw ApiException('Pass Apple Wallet invalide.');
    }

    final isAvailable = await _applePassKit.isPassLibraryAvailable();
    final canAddPasses = await _applePassKit.canAddPasses();

    if (!isAvailable || !canAddPasses) {
      throw ApiException(
        'Apple Wallet n’est pas disponible sur cet appareil.',
      );
    }

    final Uint8List passBytes;
    try {
      passBytes = base64Decode(passBase64.trim());
    } on FormatException catch (error) {
      throw ApiException('Pass Apple Wallet illisible (base64) : ${error.message}');
    }

    final isZip = passBytes.length > 4 &&
        passBytes[0] == 0x50 &&
        passBytes[1] == 0x4B;
    if (!isZip) {
      final head = passBytes
          .take(4)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      throw ApiException(
        'Données du pass corrompues (${passBytes.length} octets, début 0x$head).',
      );
    }

    try {
      await _applePassKit.addPass(passBytes);
    } on PlatformException catch (error) {
      final detail = [error.message, error.details]
          .whereType<Object>()
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(' — ');
      throw ApiException(
        detail.isEmpty
            ? 'Apple Wallet a refusé la carte (code ${error.code}).'
            : 'Apple Wallet a refusé la carte : $detail',
      );
    } catch (error) {
      throw ApiException('Apple Wallet a refusé la carte : $error');
    }
  }

  Future<void> _openGoogleWallet(String? saveUrl) async {
    if (saveUrl == null || saveUrl.isEmpty) {
      throw ApiException('Lien Google Wallet invalide.');
    }

    final uri = Uri.parse(saveUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      throw ApiException(
        'Impossible d’ouvrir Google Wallet sur cet appareil.',
      );
    }
  }
}
