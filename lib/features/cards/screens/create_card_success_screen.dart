import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/card_ready_data.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/features/wallet/services/wallet_platform_service.dart';
import 'package:provider/provider.dart';

class CreateCardSuccessScreen extends StatefulWidget {
  const CreateCardSuccessScreen({required this.data, super.key});

  final CardReadyData data;

  @override
  State<CreateCardSuccessScreen> createState() =>
      _CreateCardSuccessScreenState();
}

class _CreateCardSuccessScreenState extends State<CreateCardSuccessScreen> {
  var _isAddingToWallet = false;

  bool get _isApple {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  String _walletAddLabel(BuildContext context) =>
      _isApple ? context.l10n.walletAddApple : context.l10n.walletAddGoogle;

  Future<void> _addToWallet() async {
    if (_isAddingToWallet) return;

    final l10n = context.l10n;
    final wallet = context.read<WalletPlatformService>();
    if (!wallet.isSupported) {
      _showMessage(l10n.walletUnavailable);
      return;
    }

    setState(() => _isAddingToWallet = true);

    try {
      await wallet.addCardToWallet(widget.data.cardId);
      if (!mounted) return;
      _showMessage(l10n.walletAddedGeneric);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.walletAddError);
    } finally {
      if (mounted) {
        setState(() => _isAddingToWallet = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final walletSupported = context.read<WalletPlatformService>().isSupported;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(RoutePaths.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: Column(
                            children: [
                              const _SuccessIcon(),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                l10n.createCardSuccessTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: context.rs(AppFontSize.xxl),
                                  fontWeight: AppFontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l10n.createCardSuccessSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: context.rs(AppFontSize.md),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: CardPreview(
                            fullName: widget.data.fullName,
                            initials: widget.data.initials,
                            email: widget.data.email,
                            phone: widget.data.phone,
                            subtitle: widget.data.subtitle,
                            tagLabel: widget.data.tagLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: FilledButton.icon(
                        onPressed: walletSupported && !_isAddingToWallet
                            ? _addToWallet
                            : null,
                        icon: _isAddingToWallet
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 22,
                              ),
                        label: Text(
                          _isAddingToWallet
                              ? l10n.walletAdding
                              : _walletAddLabel(context),
                          style: const TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.bleu_primaire,
                          foregroundColor: AppColors.onPrimary,
                          disabledBackgroundColor:
                              AppColors.bleu_primaire.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => context.go(RoutePaths.home),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          backgroundColor: AppColors.iconBgMuted,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          l10n.commonGoHome,
                          style: const TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: AppColors.vert_clair,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AppColors.success,
        size: 44,
      ),
    );
  }
}
