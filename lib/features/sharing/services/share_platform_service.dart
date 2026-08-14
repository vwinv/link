import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class SharePlatformService {
  static const _whatsappPackages = ['com.whatsapp', 'com.whatsapp.w4b'];
  static const _whatsappShareComponents = {
    'com.whatsapp': 'com.whatsapp.contact.ui.picker.ExternalShareAlias',
    'com.whatsapp.w4b': 'com.whatsapp.w4b.contact.ui.picker.ExternalShareAlias',
  };

  static Future<bool> shareRichLink(
    BuildContext context, {
    required Uri uri,
    String? subject,
    String clipboardMessage = 'Lien DropOne copié dans le presse-papiers',
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(uri: uri, subject: subject),
      );

      if (result.status == ShareResultStatus.dismissed) {
        return false;
      }

      if (result.status == ShareResultStatus.success) {
        return true;
      }

      if (result.status == ShareResultStatus.unavailable) {
        await _copyToClipboard(context, uri.toString(), clipboardMessage);
      }
      return false;
    } on MissingPluginException {
      await _copyToClipboard(context, uri.toString(), clipboardMessage);
      return false;
    } catch (_) {
      await _copyToClipboard(context, uri.toString(), clipboardMessage);
      return false;
    }
  }

  static Future<bool> shareText(
    BuildContext context, {
    required String text,
    String? subject,
    String clipboardMessage = 'Contenu copié dans le presse-papiers',
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: text, subject: subject),
      );

      if (result.status == ShareResultStatus.dismissed) {
        return false;
      }

      if (result.status == ShareResultStatus.success) {
        return true;
      }

      if (result.status == ShareResultStatus.unavailable) {
        await _copyToClipboard(context, text, clipboardMessage);
      }
      return false;
    } on MissingPluginException {
      await _copyToClipboard(context, text, clipboardMessage);
      return false;
    } catch (_) {
      await _copyToClipboard(context, text, clipboardMessage);
      return false;
    }
  }

  static Future<bool> shareWhatsApp(
    BuildContext context, {
    required String url,
  }) async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final opened = await _openWhatsAppAndroid(url);
        if (opened) return true;
      } else if (!kIsWeb && Platform.isIOS) {
        final opened = await _openWhatsAppIos(url);
        if (opened) return true;
      }

      final encoded = Uri.encodeComponent(url);
      final webCandidates = [
        Uri.parse('whatsapp://send?text=$encoded'),
        Uri.parse('https://api.whatsapp.com/send?text=$encoded'),
        Uri.parse('https://wa.me/?text=$encoded'),
      ];

      for (final uri in webCandidates) {
        for (final mode in [
          LaunchMode.externalNonBrowserApplication,
          LaunchMode.platformDefault,
          LaunchMode.externalApplication,
        ]) {
          if (await _tryLaunchUrl(uri, mode)) {
            return true;
          }
        }
      }
    } on MissingPluginException {
      // Plugin natif pas chargé - repli presse-papiers ci-dessous.
    }

    if (!context.mounted) return false;

    await _copyToClipboard(
      context,
      url,
      'WhatsApp non disponible - lien DropOne copié, collez-le dans WhatsApp',
    );
    return false;
  }

  static Future<bool> _openWhatsAppAndroid(String url) async {
    final encoded = Uri.encodeComponent(url);
    final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');

    for (final mode in [
      LaunchMode.externalNonBrowserApplication,
      LaunchMode.platformDefault,
      LaunchMode.externalApplication,
    ]) {
      if (await _tryLaunchUrl(whatsappUri, mode)) {
        return true;
      }
    }

    for (final entry in _whatsappShareComponents.entries) {
      if (await _launchAndroidIntent(
        AndroidIntent(
          action: 'android.intent.action.SEND',
          type: 'text/plain',
          package: entry.key,
          componentName: entry.value,
          arguments: <String, dynamic>{
            'android.intent.extra.TEXT': url,
          },
        ),
      )) {
        return true;
      }
    }

    for (final package in _whatsappPackages) {
      if (await _launchAndroidIntent(
        AndroidIntent(
          action: 'android.intent.action.SEND',
          type: 'text/plain',
          package: package,
          arguments: <String, dynamic>{
            'android.intent.extra.TEXT': url,
          },
        ),
      )) {
        return true;
      }
    }

    for (final package in _whatsappPackages) {
      if (await _launchAndroidIntent(
        AndroidIntent(
          action: 'android.intent.action.VIEW',
          package: package,
          data: 'whatsapp://send?text=$encoded',
        ),
      )) {
        return true;
      }
    }

    return false;
  }

  static Future<bool> _launchAndroidIntent(AndroidIntent intent) async {
    try {
      await intent.launch();
      return true;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _openWhatsAppIos(String url) async {
    final encoded = Uri.encodeComponent(url);
    final candidates = [
      Uri.parse('whatsapp://send?text=$encoded'),
      Uri.parse('https://api.whatsapp.com/send?text=$encoded'),
    ];

    for (final uri in candidates) {
      if (await _tryLaunchUrl(uri, LaunchMode.externalNonBrowserApplication)) {
        return true;
      }
      if (await _tryLaunchUrl(uri, LaunchMode.externalApplication)) {
        return true;
      }
    }

    return false;
  }

  static Future<bool> _tryLaunchUrl(Uri uri, LaunchMode mode) async {
    try {
      return await launchUrl(uri, mode: mode);
    } on MissingPluginException {
      rethrow;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> copyLink(
    BuildContext context, {
    required String url,
  }) async {
    await _copyToClipboard(
      context,
      url,
      'Lien DropOne copié dans le presse-papiers',
    );
    return true;
  }

  static Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
