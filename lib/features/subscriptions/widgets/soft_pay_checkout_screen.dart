import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Ouvre un lien SoftPay (Wave / OM QR…) dans l’app.
/// Intercepte les deep links (`wave://`, etc.) pour éviter l’erreur Safari
/// « address is invalid » quand l’app wallet n’est pas installée (simulateur).
class SoftPayCheckoutScreen extends StatefulWidget {
  const SoftPayCheckoutScreen({
    super.key,
    required this.url,
    this.title = 'Paiement',
  });

  final String url;
  final String title;

  static Future<void> open(
    BuildContext context, {
    required String url,
    String title = 'Paiement',
  }) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => SoftPayCheckoutScreen(url: url, title: title),
      ),
    );
  }

  @override
  State<SoftPayCheckoutScreen> createState() => _SoftPayCheckoutScreenState();
}

class _SoftPayCheckoutScreenState extends State<SoftPayCheckoutScreen> {
  late final WebViewController _controller;
  var _loading = true;
  String? _banner;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // UA desktop → Wave affiche souvent le QR au lieu de forcer l’app.
      ..setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _banner =
                  'Page de paiement indisponible. Réessayez ou ouvrez Wave manuellement.';
            });
          },
          onNavigationRequest: (request) {
            final target = Uri.tryParse(request.url);
            if (target == null) return NavigationDecision.prevent;

            if (target.scheme == 'http' || target.scheme == 'https') {
              return NavigationDecision.navigate;
            }

            // Deep link wallet (wave://, orangemoney://…).
            _tryOpenWallet(target);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(uri);

    // Tentative d’ouverture directe de l’app si Universal Link / app installée.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryOpenWallet(uri, silentIfMissing: true);
    });
  }

  Future<void> _tryOpenWallet(
    Uri uri, {
    bool silentIfMissing = false,
  }) async {
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (opened || !mounted) return;
      if (!silentIfMissing) {
        setState(() {
          _banner =
              'Application wallet introuvable. Payez via le QR / la page ci-dessous, puis revenez dans DropOne.';
        });
      }
    } catch (_) {
      if (!mounted || silentIfMissing) return;
      setState(() {
        _banner =
            'Application wallet introuvable. Payez via le QR / la page ci-dessous, puis revenez dans DropOne.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_banner != null)
            Material(
              color: const Color(0xFFFFF8E1),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFF9A825),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _banner!,
                        style: const TextStyle(
                          color: Color(0xFF5D4037),
                          height: 1.35,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: WebViewWidget(controller: _controller)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bleu_primaire,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('J’ai payé — Retour'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
