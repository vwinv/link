import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_social_link.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  static const _displayedPlatforms = [
    CardSocialPlatform.linkedin,
    CardSocialPlatform.instagram,
    CardSocialPlatform.whatsapp,
  ];

  List<CardSocialLink> _socialLinks = [];
  var _isLoadingSocial = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionsProvider>().refresh();
      _loadSocialLinks();
    });
  }

  Future<void> _loadSocialLinks() async {
    try {
      final links = await context
          .read<CardsApiService>()
          .fetchSocialLinks(widget.card.id);
      if (!mounted) return;
      setState(() {
        _socialLinks = links;
        _isLoadingSocial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSocial = false);
    }
  }

  BusinessCard get _card {
    return context.watch<CardsProvider>().cards.firstWhere(
          (item) => item.id == widget.card.id,
          orElse: () => widget.card,
        );
  }

  String? _socialUrl(CardSocialPlatform platform) {
    for (final link in _socialLinks) {
      if (link.platform == platform && link.isConfigured) {
        return link.url;
      }
    }
    return null;
  }

  Future<void> _openSocialLink(CardSocialPlatform platform) async {
    final url = _socialUrl(platform);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.myCardSocialNotConfigured(platform.labelL10n(context.l10n)),
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.myCardLinkOpenError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final card = _card;
    final team = context.watch<TeamsProvider>().myTeam;
    final hasPortfolio = context.watch<SubscriptionsProvider>().hasPortfolioAccess;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.bleu_primaire,
                    ),
                    label: Text(
                      l10n.commonBack,
                      style: const TextStyle(
                        color: AppColors.bleu_primaire,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.myCardTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.lg),
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await openEditCardInfo(context, card: card);
                      if (!mounted) return;
                      _loadSocialLinks();
                    },
                    child: Text(
                      l10n.commonEdit,
                      style: const TextStyle(
                        color: AppColors.bleu_primaire,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  CardPreview(
                    fullName: card.fullName,
                    initials: card.initials,
                    avatarUrl: card.avatarImageUrl,
                    email: card.email ?? '',
                    phone: card.phone,
                    subtitle: card.subtitle,
                    style: card.theme.style,
                    showQr: card.theme.showQrCode,
                    qrData: ShareCardHelper.publicUrl(card.slug),
                    companyLogoUrl: card.isProfessional
                        ? card.companyLogoImageUrl(team)
                        : null,
                    tagLabel: card.kind.tagLabelL10n(l10n),
                    cardBadge: card.theme.cardBadge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSizes.buttonHeight,
                          child: FilledButton.icon(
                            onPressed: () => openShareCard(context, card),
                            icon: const Icon(Icons.ios_share_rounded, size: 20),
                            label: Text(l10n.commonShare),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.bleu_primaire,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: AppSizes.buttonHeight,
                          child: FilledButton.icon(
                            onPressed: () => openWalletScreen(context, card),
                            icon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20,
                            ),
                            label: Text(l10n.walletTitle),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.textPrimary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionLabel(l10n.myCardSocialNetworks),
                  const SizedBox(height: AppSpacing.md),
                  if (_isLoadingSocial)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      children: [
                        for (var i = 0; i < _displayedPlatforms.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.md),
                          _SocialNetworkIcon(
                            platform: _displayedPlatforms[i],
                            isConfigured:
                                _socialUrl(_displayedPlatforms[i]) != null,
                            onTap: () =>
                                _openSocialLink(_displayedPlatforms[i]),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Expanded(child: _SectionLabel(l10n.myCardPortfolio)),
                      if (!hasPortfolio)
                        TextButton(
                          onPressed: () => openLinkPremium(context),
                          child: Text(
                            l10n.commonUnlock,
                            style: const TextStyle(
                              color: AppColors.bleu_primaire,
                              fontWeight: AppFontWeight.semiBold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (hasPortfolio)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        l10n.myCardPortfolioLinked,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.md),
                        ),
                      ),
                    )
                  else
                    _PortfolioPremiumBanner(
                      message: l10n.myCardPortfolioPremium,
                      onTap: () => openLinkPremium(context),
                    ),
                ],
              ),
            ),
          ],
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

class _SocialNetworkIcon extends StatelessWidget {
  const _SocialNetworkIcon({
    required this.platform,
    required this.isConfigured,
    required this.onTap,
  });

  final CardSocialPlatform platform;
  final bool isConfigured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final asset = platform.iconAsset;

    return Material(
      color: isConfigured ? AppColors.surface : AppColors.iconBgMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isConfigured ? AppColors.border : Colors.transparent,
            ),
          ),
          child: asset == null
              ? Icon(
                  Icons.link_rounded,
                  color: isConfigured
                      ? platform.brandColor
                      : AppColors.textTertiaire,
                )
              : Opacity(
                  opacity: isConfigured ? 1 : 0.35,
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
        ),
      ),
    );
  }
}

class _PortfolioPremiumBanner extends StatelessWidget {
  const _PortfolioPremiumBanner({
    required this.message,
    required this.onTap,
  });

  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconBgMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.or,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.rs(AppFontSize.md),
                    fontWeight: AppFontWeight.medium,
                    height: 1.35,
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
