import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_badge_type.dart';
import 'package:linkflutter/features/cards/models/card_style.dart';
import 'package:linkflutter/features/cards/models/card_theme_settings.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

class CustomizeCardScreen extends StatefulWidget {
  const CustomizeCardScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<CustomizeCardScreen> createState() => _CustomizeCardScreenState();
}

class _CustomizeCardScreenState extends State<CustomizeCardScreen> {
  late CardStyle _selectedStyle;
  late bool _showQrCode;
  late CardBadgeType _selectedCardBadge;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.card.theme.style;
    _showQrCode = widget.card.theme.showQrCode;
    _selectedCardBadge = widget.card.theme.cardBadge;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionsProvider>().refresh();
    });
  }

  void _toggleCardBadge() {
    setState(() {
      _selectedCardBadge = _selectedCardBadge == CardBadgeType.personalTag
          ? CardBadgeType.companyLogo
          : CardBadgeType.personalTag;
    });
  }

  CardThemeSettings get _draftTheme {
    final styleChanged = _selectedStyle != widget.card.theme.style;
    return CardThemeSettings(
      style: _selectedStyle,
      showQrCode: _showQrCode,
      cardBadge: widget.card.isProfessional
          ? _selectedCardBadge
          : CardBadgeType.personalTag,
      proDesignId: styleChanged ? null : widget.card.theme.proDesignId,
      brandColor: styleChanged ? null : widget.card.theme.brandColor,
      useCompanyColors:
          styleChanged ? false : widget.card.theme.useCompanyColors,
    );
  }

  bool get _hasChanges => _draftTheme != widget.card.theme;

  Future<void> _save() async {
    if (_isSaving || !_hasChanges) return;

    final theme = _draftTheme;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final cardsProvider = context.read<CardsProvider>();
    final cardsApi = context.read<CardsApiService>();

    setState(() => _isSaving = true);

    cardsProvider.replaceCard(widget.card.copyWith(theme: theme));

    try {
      final updated = await cardsApi.updateCardTheme(widget.card.id, theme);
      if (!mounted) return;

      cardsProvider.replaceCard(updated);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.customizeSaved)),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.customizeSyncError)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final team = context.watch<TeamsProvider>().myTeam;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
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
                    l10n.customizeTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(AppFontSize.lg),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CardPreview(
                      fullName: card.fullName,
                      initials: card.initials,
                      avatarUrl: card.avatarImageUrl,
                      email: card.email ?? '',
                      phone: card.phone,
                      subtitle: card.subtitle,
                      style: _selectedStyle,
                      showQr: _showQrCode,
                      qrData: ShareCardHelper.publicUrl(card.slug),
                      companyLogoUrl: card.isProfessional
                          ? card.companyLogoImageUrl(team)
                          : null,
                      tagLabel: card.kind.tagLabel,
                      cardBadge: card.isProfessional
                          ? _selectedCardBadge
                          : CardBadgeType.personalTag,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionLabel(l10n.customizeStyleSection),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.05,
                      children: CardStyle.values.map((style) {
                        return _StyleOptionTile(
                          style: style,
                          isSelected: style == _selectedStyle,
                          onTap: () => setState(() => _selectedStyle = style),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _PremiumDesignsBanner(
                      onTap: () => openProfessionalDesignsOrPremium(
                        context,
                        card: card,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionLabel(l10n.customizeOptionsSection),
                    const SizedBox(height: AppSpacing.md),
                    _QrToggleTile(
                      value: _showQrCode,
                      onChanged: (value) => setState(() => _showQrCode = value),
                    ),
                    if (card.isProfessional) ...[
                      const SizedBox(height: AppSpacing.md),
                      _CardBadgeTile(
                        card: card,
                        cardBadge: _selectedCardBadge,
                        onTap: _toggleCardBadge,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                  ],
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
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: FilledButton(
                  onPressed: (_isSaving || !_hasChanges) ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.bleu_primaire,
                    disabledBackgroundColor:
                        AppColors.bleu_primaire.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.bleu_primaire.withValues(alpha: 0.35),
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
                          l10n.commonSave,
                          style: const TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: AppFontSize.md,
                            fontWeight: AppFontWeight.semiBold,
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
      color: AppColors.iconBgMuted,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textTertiaire,
        fontSize: context.rs(12),
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _StyleOptionTile extends StatelessWidget {
  const _StyleOptionTile({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  static const _labelBackground = Color(0xFFF5F5F7);

  final CardStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(isSelected ? 3 : 1),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bleu_primaire : AppColors.border,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _labelBackground,
            borderRadius: BorderRadius.circular(17),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ColoredBox(
                      color: style.background,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: style.previewForeground,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _PreviewBar(
                                    color: style.previewForeground,
                                    widthFactor: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  _PreviewBar(
                                    color: style.previewForeground
                                        .withValues(alpha: 0.75),
                                    widthFactor: 0.62,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.bleu_primaire,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.onPrimary,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                color: _labelBackground,
                alignment: Alignment.center,
                child: Text(
                  style.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(13),
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({
    required this.color,
    required this.widthFactor,
  });

  final Color color;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * widthFactor,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}

class _PremiumDesignsBanner extends StatelessWidget {
  const _PremiumDesignsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: const Color(0xFF151518),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFF2A2A2E)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.or_fonce,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.or,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customizeProDesigns,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.customizeProDesignsSubtitle,
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.45),
                        fontSize: context.rs(AppFontSize.sm),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.or_fonce,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  '30',
                  style: TextStyle(
                    color: AppColors.or,
                    fontSize: 12,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onPrimary.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrToggleTile extends StatelessWidget {
  const _QrToggleTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.customizeShowQr,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(AppFontSize.md),
                fontWeight: AppFontWeight.medium,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.success,
            activeThumbColor: AppColors.onPrimary,
          ),
        ],
      ),
    );
  }
}

class _CardBadgeTile extends StatelessWidget {
  const _CardBadgeTile({
    required this.card,
    required this.cardBadge,
    required this.onTap,
  });

  final BusinessCard card;
  final CardBadgeType cardBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconBgMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.customizeCardBadge,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cardBadge.optionSubtitleFor(card.kind),
                      style: TextStyle(
                        color: AppColors.textTertiaire,
                        fontSize: context.rs(AppFontSize.sm),
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
