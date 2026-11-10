import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/points/models/points_overview.dart';
import 'package:linkflutter/features/points/services/points_api_service.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:provider/provider.dart';

/// Aligné sur la liste des visiteurs.
abstract final class _H {
  static const divider = Color(0xFFE5E5EA);
  static const meta = Color(0xFF8E8E93);
  static const subtitle = Color(0xFF6C6C70);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFE7F6EC);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFDECEC);
  static const blue = Color(0xFF0A6BFF);
  static const blueSoft = Color(0xFFE8F0FF);
}

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  PointsOverview? _overview;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await context.read<PointsApiService>().fetchOverview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.referralLoadError;
        _loading = false;
      });
    }
  }

  String get _storeUrl {
    if (!kIsWeb && Platform.isAndroid) return ApiConfig.playStoreUrl;
    return ApiConfig.appStoreUrl;
  }

  Future<void> _shareInvite() async {
    final code = _overview?.referralCode;
    if (code == null || code.isEmpty) return;
    final text = context.l10n.referralShareText(code, _storeUrl);
    await SharePlatformService.shareText(context, text: text);
  }

  String _formatPoints(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String _reasonLabel(String reason) {
    final l10n = context.l10n;
    return switch (reason) {
      'REFERRAL_SUBSCRIBE' => l10n.referralLedgerReferral,
      'CARD_VISIT' => l10n.referralLedgerVisit,
      'PURCHASE' => l10n.referralLedgerPurchase,
      'ADJUSTMENT' => l10n.referralLedgerAdjustment,
      _ => reason,
    };
  }

  IconData _reasonIcon(String reason) {
    return switch (reason) {
      'REFERRAL_SUBSCRIBE' => Icons.person_add_alt_1_rounded,
      'CARD_VISIT' => Icons.visibility_outlined,
      'PURCHASE' => Icons.shopping_bag_outlined,
      'ADJUSTMENT' => Icons.tune_rounded,
      _ => Icons.stars_rounded,
    };
  }

  Map<String, List<PointsLedgerItem>> _groupByDay(
    List<PointsLedgerItem> items,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final groups = <String, List<PointsLedgerItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final local = item.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final label = day == today
          ? context.l10n.cardVisitorsToday
          : day == yesterday
              ? context.l10n.cardVisitorsYesterday
              : DateFormat.MMMMd(locale).format(day).toUpperCase();
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overview = _overview;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  const LinkBackButton(),
                  Expanded(
                    child: Text(
                      l10n.referralTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(17),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.bleu_clair,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: const Icon(
                                    Icons.wifi_off_rounded,
                                    color: AppColors.bleu_primaire,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: context.rs(AppFontSize.sm),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                FilledButton(
                                  onPressed: _load,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.bleu_primaire,
                                    minimumSize: const Size(140, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                  ),
                                  child: Text(l10n.commonRetry),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.bleu_primaire,
                          onRefresh: _load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenHorizontal,
                              AppSpacing.lg,
                              AppSpacing.screenHorizontal,
                              AppSpacing.xxxl,
                            ),
                            children: [
                              _HeroBalance(
                                overview: overview!,
                                formatPoints: _formatPoints,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _CodeBlock(
                                code: overview.referralCode ?? '—',
                                onShare: _shareInvite,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              _SectionTitle(l10n.referralHowTitle),
                              const SizedBox(height: AppSpacing.md),
                              _HowStep(
                                icon: Icons.person_add_alt_1_rounded,
                                title: l10n.referralLedgerReferral,
                                detail:
                                    '+${_formatPoints(overview.referralSubscribeRewardPoints)} ${l10n.referralPointsUnit}',
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _HowStep(
                                icon: Icons.visibility_outlined,
                                title: l10n.referralLedgerVisit,
                                detail:
                                    '+${_formatPoints(overview.visitRewardPoints)} ${l10n.referralPointsUnit}',
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _HowStep(
                                icon: Icons.payments_outlined,
                                title:
                                    '1 ${l10n.referralPointsUnit} = ${overview.fcfaPerPoint} FCFA',
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              _SectionTitle(l10n.referralHistoryTitle),
                              const SizedBox(height: AppSpacing.md),
                              if (overview.ledger.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                  ),
                                  child: Text(
                                    l10n.referralHistoryEmpty,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: context.rs(15),
                                    ),
                                  ),
                                )
                              else
                                ..._groupByDay(overview.ledger).entries.expand(
                                  (entry) {
                                    final items = entry.value;
                                    return [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                          top: 4,
                                        ),
                                        child: Text(
                                          entry.key,
                                          style: TextStyle(
                                            color: _H.meta,
                                            fontSize: context.rs(11),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      for (var i = 0; i < items.length; i++) ...[
                                        _LedgerRow(
                                          icon: _reasonIcon(items[i].reason),
                                          label: _reasonLabel(items[i].reason),
                                          createdAt: items[i].createdAt,
                                          amountLabel:
                                              '${items[i].amountPoints > 0 ? '+' : ''}${_formatPoints(items[i].amountPoints)} pts',
                                          positive: items[i].amountPoints >= 0,
                                        ),
                                        if (i < items.length - 1)
                                          const Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            color: _H.divider,
                                          ),
                                      ],
                                      const SizedBox(height: 12),
                                    ];
                                  },
                                ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textTertiaire,
        fontSize: context.rs(12),
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _HeroBalance extends StatelessWidget {
  const _HeroBalance({
    required this.overview,
    required this.formatPoints,
  });

  final PointsOverview overview;
  final String Function(double) formatPoints;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0D10),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bleu_primaire,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  l10n.referralInvitedCount(overview.referralCount),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: context.rs(12),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.referralBalanceLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: context.rs(13),
              fontWeight: AppFontWeight.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${formatPoints(overview.balancePoints)} ${l10n.referralPointsUnit}',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rs(32),
              fontWeight: AppFontWeight.bold,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.referralBalanceFcfa(
              overview.balanceFcfa.toStringAsFixed(0),
            ),
            style: TextStyle(
              color: AppColors.bleu_primaire,
              fontSize: context.rs(AppFontSize.sm),
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.code,
    required this.onShare,
  });

  final String code;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.referralYourCode,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.rs(13),
              fontWeight: AppFontWeight.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: context.rs(15),
                fontWeight: AppFontWeight.semiBold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onShare,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bleu_primaire,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(
                l10n.referralShare,
                style: TextStyle(
                  fontSize: context.rs(AppFontSize.sm),
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowStep extends StatelessWidget {
  const _HowStep({
    required this.icon,
    required this.title,
    this.detail,
  });

  final IconData icon;
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bleu_clair,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.bleu_primaire, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(AppFontSize.sm),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.rs(12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.icon,
    required this.label,
    required this.createdAt,
    required this.amountLabel,
    required this.positive,
  });

  final IconData icon;
  final String label;
  final DateTime createdAt;
  final String amountLabel;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(createdAt.toLocal());
    final iconBg = positive ? _H.greenSoft : _H.redSoft;
    final iconColor = positive ? _H.green : _H.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 12, color: _H.meta),
                    const SizedBox(width: 3),
                    Text(
                      time,
                      style: TextStyle(
                        color: _H.meta,
                        fontSize: context.rs(11),
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: TextStyle(
                        color: _H.meta,
                        fontSize: context.rs(11),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        positive
                            ? context.l10n.referralLedgerCredit
                            : context.l10n.referralLedgerDebit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _H.meta,
                          fontSize: context.rs(11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountLabel,
            style: TextStyle(
              color: positive ? _H.green : _H.red,
              fontSize: context.rs(14),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
