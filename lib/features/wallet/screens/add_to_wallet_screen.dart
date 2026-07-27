import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/features/wallet/services/wallet_platform_service.dart';
import 'package:linkflutter/features/wallet/widgets/wallet_pass_preview.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

class AddToWalletScreen extends StatefulWidget {
  const AddToWalletScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<AddToWalletScreen> createState() => _AddToWalletScreenState();
}

class _AddToWalletScreenState extends State<AddToWalletScreen> {
  var _isAdding = false;

  bool get _isApple {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  String _walletName(BuildContext context) =>
      _isApple ? context.l10n.walletAppleName : context.l10n.walletGoogleName;

  String _walletAddLabel(BuildContext context) =>
      _isApple ? context.l10n.walletAddApple : context.l10n.walletAddGoogle;

  Future<void> _addToWallet() async {
    if (_isAdding) return;

    final l10n = context.l10n;
    final wallet = context.read<WalletPlatformService>();
    if (!wallet.isSupported) {
      _showMessage(l10n.walletUnavailable);
      return;
    }

    setState(() => _isAdding = true);
    try {
      await wallet.addCardToWallet(widget.card.id);
      if (!mounted) return;
      _showMessage(l10n.walletAdded(_walletName(context)));
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.walletAddError);
    } finally {
      if (mounted) setState(() => _isAdding = false);
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
    final team = context.watch<TeamsProvider>().myTeam;
    final companyLogoUrl = widget.card.companyLogoImageUrl(team);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CloseButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    l10n.walletTitle,
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: context.rs(AppFontSize.lg),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WalletPassPreview(
                            card: widget.card,
                            companyLogoUrl: companyLogoUrl,
                            onLinkTap: () => SharePlatformService.copyLink(
                              context,
                              url: ShareCardHelper.publicUrl(widget.card.slug),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            _walletAddLabel(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: context.rs(26),
                              fontWeight: AppFontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.walletSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.onPrimary.withValues(alpha: 0.55),
                              fontSize: context.rs(AppFontSize.md),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: FilledButton.icon(
                  onPressed: _isAdding ? null : _addToWallet,
                  icon: _isAdding
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Icon(
                          _isApple ? Icons.apple : Icons.account_balance_wallet,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                  label: Text(
                    _isAdding ? l10n.walletAdding : _walletAddLabel(context),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppFontSize.md,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.onPrimary,
                    disabledBackgroundColor:
                        AppColors.onPrimary.withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
