import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/deep_link/deep_link_service.dart';
import 'package:linkflutter/core/network/network_status.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PublicPortfolioScreen extends StatefulWidget {
  const PublicPortfolioScreen({
    required this.slug,
    this.layout,
    this.color,
    this.cardId,
    this.canSaveStyle = false,
    super.key,
  });

  final String slug;
  final String? layout;
  final String? color;
  final String? cardId;

  /// Aperçu depuis Personnaliser : Enregistrer applique le thème choisi.
  final bool canSaveStyle;

  @override
  State<PublicPortfolioScreen> createState() => _PublicPortfolioScreenState();
}

class _PublicPortfolioScreenState extends State<PublicPortfolioScreen> {
  late final WebViewController _controller;
  var _isLoading = true;
  var _hasError = false;
  var _offline = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF070B18))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            context.read<NetworkStatus>().reportOnline();
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (!isFatalPageLoadError(
              isForMainFrame: error.isForMainFrame,
              errorCode: error.errorCode,
            )) {
              return;
            }
            final offline = looksLikeOfflineWebError(
              errorCode: error.errorCode,
              description: error.description,
              errorTypeName: error.errorType?.name,
            );
            if (offline) context.read<NetworkStatus>().reportOffline();
            setState(() {
              _isLoading = false;
              _hasError = true;
              _offline = offline;
            });
          },
        ),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final headers = <String, String>{};
    final token = context.read<ApiClient>().accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      await _controller.loadRequest(
        Uri.parse(
          ApiConfig.portfolioPageLoadUrl(
            widget.slug,
            layout: widget.layout,
            color: widget.color,
          ),
        ),
        headers: headers,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _offline = true;
      });
      context.read<NetworkStatus>().reportOffline();
    }
  }

  Future<void> _saveStyle() async {
    final cardId = widget.cardId;
    final layout = widget.layout;
    final color = widget.color;
    if (_saving || cardId == null || layout == null || color == null) return;
    setState(() => _saving = true);
    try {
      await context.read<CardsApiService>().savePortfolioStyle(
            cardId: cardId,
            layoutId: layout,
            colorId: color,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 403) {
        await openLinkPremium(
          context,
          preferredAudience: OfferAudience.portfolio,
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.portfolioStyleSaveError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _close() async {
    await context.read<DeepLinkService>().dismissPublicPortfolio(widget.slug);
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    final signedIn = context.read<AuthProvider>().isAuthenticated;
    context.go(signedIn ? RoutePaths.home : RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final showSave = widget.canSaveStyle &&
        widget.cardId != null &&
        widget.layout != null &&
        widget.color != null;

    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: AppColors.onPrimary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _saving ? null : _close,
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _offline
                      ? NetworkStatus.offlineMessage
                      : 'Portfolio introuvable',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          if (showSave)
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LinkPrimaryButton(
                    label: context.l10n.portfolioEditorSave,
                    borderRadius: 28,
                    isLoading: _saving,
                    onPressed: _saveStyle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
