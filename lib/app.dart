import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linkflutter/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/config/theme/app_theme.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/deep_link/deep_link_service.dart';
import 'package:linkflutter/features/app_update/widgets/app_update_bottom_sheet.dart';
import 'package:linkflutter/features/app_update/widgets/app_update_gate.dart';
import 'package:linkflutter/features/notifications/services/push_notifications_service.dart';
import 'package:linkflutter/providers/app_providers.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/locale_provider.dart';
import 'package:linkflutter/providers/notifications_provider.dart';
import 'package:provider/provider.dart';

class LinkApp extends StatelessWidget {
  const LinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: const AppUpdateGate(child: _AppView()),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  GoRouter? _router;
  var _deepLinksInitialized = false;
  var _pushBound = false;
  AuthProvider? _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= AppRouter.create(context);
    _initializeDeepLinks();
    _bindPushLifecycle();
  }

  void _initializeDeepLinks() {
    if (_deepLinksInitialized || _router == null) return;
    _deepLinksInitialized = true;

    context.read<DeepLinkService>().initialize((link) {
      final base = link.isPortfolio
          ? RoutePaths.publicPortfolio
          : RoutePaths.publicCard;
      _router?.go('$base/${link.slug}');
    });
  }

  void _bindPushLifecycle() {
    if (_pushBound) return;
    _pushBound = true;
    _auth = context.read<AuthProvider>();
    _auth!.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthChanged());
  }

  Future<void> _onAuthChanged() async {
    final auth = _auth;
    if (auth == null || !mounted) return;

    final push = context.read<PushNotificationsService>();
    final notifications = context.read<NotificationsProvider>();

    if (auth.isAuthenticated) {
      push.onForegroundMessage = (_) {
        notifications.refreshUnreadCount();
        notifications.load(force: true);
      };
      await push.start();
      notifications.startPolling();
      await notifications.refreshUnreadCount();
    } else {
      push.onForegroundMessage = null;
      await push.stop();
      notifications.stopPolling();
      notifications.clear();
    }
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp.router(
      title: 'DropOne',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router!,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final incoming = context.watch<NotificationsProvider>().latestIncoming;
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.15,
            ),
          ),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (incoming != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: _IncomingNotificationBanner(
                        title: incoming.title,
                        body: incoming.body,
                        onTap: () {
                          context.read<NotificationsProvider>().clearIncoming();
                          _router?.push(RoutePaths.notifications);
                        },
                        onClose: () {
                          context.read<NotificationsProvider>().clearIncoming();
                        },
                      ),
                    ),
                  ),
                ),
              const AppUpdateBottomSheetOverlay(),
            ],
          ),
        );
      },
    );
  }
}

class _IncomingNotificationBanner extends StatelessWidget {
  const _IncomingNotificationBanner({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onClose,
  });

  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0C0D10),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AppAssets.icone,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.bleu_primaire,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
