import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/points/services/points_api_service.dart';
import 'package:provider/provider.dart';

/// Saisie optionnelle du code à la création de compte (OAuth sans code).
Future<void> showReferralCodePromptIfNeeded(BuildContext context) async {
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ReferralCodePromptSheet(),
  );
}

class _ReferralCodePromptSheet extends StatefulWidget {
  const _ReferralCodePromptSheet();

  @override
  State<_ReferralCodePromptSheet> createState() =>
      _ReferralCodePromptSheetState();
}

class _ReferralCodePromptSheetState extends State<_ReferralCodePromptSheet> {
  final _controller = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<PointsApiService>().applyReferralCode(code);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.referralCodeApplied)),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.referralCodeApplyError;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.referralEnterCodeTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(AppFontSize.xl),
                fontWeight: AppFontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.referralFirstLoginHint,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(AppFontSize.sm),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _controller,
              enabled: !_loading,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(AppFontSize.md),
                fontWeight: AppFontWeight.semiBold,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: l10n.referralEnterCodeHint,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiaire,
                  fontWeight: AppFontWeight.regular,
                  letterSpacing: 0,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.bleu_primaire,
                    width: 1.6,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: context.rs(13),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bleu_primaire,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.referralApply,
                        style: TextStyle(
                          fontWeight: AppFontWeight.semiBold,
                          fontSize: context.rs(AppFontSize.md),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pop(),
              child: Text(
                l10n.referralSkipCode,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
