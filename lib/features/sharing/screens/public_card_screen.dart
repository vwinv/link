import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/deep_link/deep_link_service.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/network/network_status.dart';
import 'package:linkflutter/features/sharing/public_card_web_bridge.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PublicCardScreen extends StatefulWidget {
  const PublicCardScreen({
    required this.slug,
    this.asGuestPreview = false,
    super.key,
  });

  final String slug;

  /// « Voir ma carte » : même rendu qu’un visiteur sans DropOne.
  final bool asGuestPreview;

  @override
  State<PublicCardScreen> createState() => _PublicCardScreenState();
}

class _PublicCardScreenState extends State<PublicCardScreen> {
  static const _loadTimeout = Duration(seconds: 45);

  late final WebViewController _controller;
  Timer? _loadTimer;
  var _isLoading = true;
  var _hasError = false;
  var _offline = false;
  var _isSaving = false;
  var _savedInLink = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        unawaited(ensureUserWorkspaceLoaded(context));
      }
      if (!widget.asGuestPreview) {
        unawaited(
          context.read<SharingApiService>().recordPublicCardView(widget.slug),
        );
      }
    });
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0C0D10))
      ..addJavaScriptChannel(
        PublicCardWebBridge.channelName,
        onMessageReceived: (message) {
          if (message.message == PublicCardWebBridge.previewLink) {
            _showPreviewShareHint();
            return;
          }
          if (message.message == PublicCardWebBridge.saveContact) {
            _registerContactInLink();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            final portfolioSlug = _portfolioSlugFromUri(uri);
            if (portfolioSlug != null) {
              if (widget.asGuestPreview) {
                _showPreviewShareHint();
              } else {
                unawaited(_openVisitorPortfolio(portfolioSlug));
              }
              return NavigationDecision.prevent;
            }

            if (widget.asGuestPreview && _shouldBlockInPreview(uri)) {
              _showPreviewShareHint();
              return NavigationDecision.prevent;
            }
            if (_shouldOpenExternally(uri)) {
              unawaited(_openExternalUri(uri));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (!mounted) return;
            _startLoadTimeout();
            setState(() {
              _isLoading = true;
              _hasError = false;
              _offline = false;
            });
          },
          onPageFinished: (_) async {
            _cancelLoadTimeout();
            if (!mounted) return;
            setState(() => _isLoading = false);
            if (mounted) context.read<NetworkStatus>().reportOnline();
            try {
              await _controller.runJavaScript(
                PublicCardWebBridge.injectScript(
                  asGuestPreview: widget.asGuestPreview,
                ),
              );
            } catch (_) {}
          },
          onWebResourceError: (error) {
            _cancelLoadTimeout();
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
    _loadPage();
  }

  @override
  void dispose() {
    _cancelLoadTimeout();
    super.dispose();
  }

  void _startLoadTimeout() {
    _cancelLoadTimeout();
    _loadTimer = Timer(_loadTimeout, () {
      if (!mounted || !_isLoading) return;
      context.read<NetworkStatus>().reportOffline();
      setState(() {
        _isLoading = false;
        _hasError = true;
        _offline = true;
      });
    });
  }

  void _cancelLoadTimeout() {
    _loadTimer?.cancel();
    _loadTimer = null;
  }

  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _offline = false;
    });
    _startLoadTimeout();

    final headers = <String, String>{};
    // Aperçu propriétaire : pas de token → même page qu’un visiteur anonyme.
    if (!widget.asGuestPreview) {
      final token = context.read<ApiClient>().accessToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    await _controller.loadRequest(
      Uri.parse(
        ApiConfig.publicPageLoadUrl(
          widget.slug,
          asGuestPreview: widget.asGuestPreview,
        ),
      ),
      headers: headers,
    );
  }

  Future<void> _registerContactInLink() async {
    if (_isSaving || _savedInLink || !mounted) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      _showSnackBar('Connectez-vous pour enregistrer ce contact dans DropOne.');
      if (mounted) {
        final returnPath = '${RoutePaths.publicCard}/${widget.slug}';
        context.push(
          '${RoutePaths.login}?return=${Uri.encodeComponent(returnPath)}',
        );
      }
      return;
    }

    if (context.read<CardsProvider>().cards.any((card) => card.slug == widget.slug)) {
      _showSnackBar(
        'C’est votre carte. Partagez ce lien pour qu’une autre personne vous enregistre.',
      );
      return;
    }

    setState(() => _isSaving = true);

    final contacts = context.read<ContactsProvider>();
    final sharing = context.read<SharingApiService>();

    try {
      final contact = await contacts.exchangeFromCardSlug(widget.slug);
      await sharing.recordPublicCardSave(widget.slug);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _savedInLink = true;
      });
      _showSnackBar('${contact.fullName} ajouté à vos contacts DropOne.');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('Impossible d’enregistrer ce contact. Réessayez.');
    }
  }

  bool _shouldOpenExternally(Uri uri) {
    return uri.scheme == 'tel' || uri.scheme == 'mailto' || uri.scheme == 'sms';
  }

  bool _shouldBlockInPreview(Uri uri) {
    if (_shouldOpenExternally(uri)) return true;
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final path = uri.path;
      final isCardPage =
          path.contains('/cards/') || path.contains('/sharing/public/');
      return !isCardPage;
    }
    return false;
  }

  /// Extrait le slug depuis `/portfolios/{slug}`.
  String? _portfolioSlugFromUri(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final index = segments.indexOf('portfolios');
    if (index < 0 || index + 1 >= segments.length) return null;
    final slug = segments[index + 1].trim();
    return slug.isEmpty ? null : slug;
  }

  /// Ouvre le portfolio dans l’écran dédié (style à jour, sans cache WebView carte).
  Future<void> _openVisitorPortfolio(String slug) async {
    if (!mounted) return;
    await context.push('${RoutePaths.publicPortfolio}/$slug');
  }

  Future<void> _openExternalUri(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnackBar('Impossible d’ouvrir ce lien.');
    }
  }

  void _showPreviewShareHint() {
    _showSnackBar(context.l10n.previewShareLinksHint);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _close(BuildContext context) async {
    if (_savedInLink && context.read<AuthProvider>().isAuthenticated) {
      await context.read<ContactsProvider>().load();
    }

    await context.read<DeepLinkService>().dismissPublicCard(widget.slug);

    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
      return;
    }

    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
    context.go(isAuthenticated ? RoutePaths.home : RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isOwnCard = context
        .watch<CardsProvider>()
        .cards
        .any((card) => card.slug == widget.slug);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (!_hasError)
                  Positioned.fill(
                    child: WebViewWidget(
                      key: ValueKey('public-card-${widget.slug}'),
                      controller: _controller,
                    ),
                  ),
                if (_hasError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _offline
                                ? NetworkStatus.offlineMessage
                                : 'Impossible d’afficher cette carte.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.onPrimary.withValues(
                                alpha: 0.75,
                              ),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _loadPage,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_isLoading && !_hasError)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.onPrimary,
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _CloseButton(onPressed: () => _close(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_hasError && !isOwnCard)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving || _savedInLink
                        ? null
                        : _registerContactInLink,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bleu_primaire,
                      disabledBackgroundColor:
                          AppColors.bleu_primaire.withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Text(
                            _savedInLink
                                ? 'Contact enregistré dans DropOne'
                                : auth.isAuthenticated
                                    ? 'Enregistrer dans DropOne'
                                    : 'Se connecter pour enregistrer',
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
