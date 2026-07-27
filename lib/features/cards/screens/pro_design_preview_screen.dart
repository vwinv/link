import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/color_utils.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/pro_design_layout.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/arc_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/bubble_design.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_body.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_canvas.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

class ProDesignPreviewScreen extends StatefulWidget {
  const ProDesignPreviewScreen({
    required this.card,
    required this.template,
    this.useCompanyColors = false,
    this.companyColorHex,
    super.key,
  });

  final BusinessCard card;
  final ProDesignTemplate template;
  final bool useCompanyColors;
  final String? companyColorHex;

  @override
  State<ProDesignPreviewScreen> createState() => _ProDesignPreviewScreenState();
}

class _ProDesignPreviewScreenState extends State<ProDesignPreviewScreen> {
  var _isApplying = false;

  String get _subtitle {
    final subtitle = widget.card.subtitle;
    if (subtitle.isNotEmpty) return subtitle;
    return widget.card.company?.trim() ?? '';
  }

  String? get _brandColorHex {
    if (!widget.useCompanyColors) return null;
    if (widget.companyColorHex != null && widget.companyColorHex!.isNotEmpty) {
      return widget.companyColorHex;
    }

    final branded = widget.template.brandColor;
    if (branded != null) return colorToHex(branded);

    final accent = widget.template.accent;
    if (accent != null) return colorToHex(accent);

    return null;
  }

  Future<void> _applyTemplate() async {
    if (_isApplying) return;

    setState(() => _isApplying = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final cardsProvider = context.read<CardsProvider>();
    final cardsApi = context.read<CardsApiService>();

    final useCompanyColors = widget.useCompanyColors;
    final brandHex = _brandColorHex;

    if (useCompanyColors && (brandHex == null || brandHex.isEmpty)) {
      if (!mounted) return;
      final l10n = context.l10n;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.proDesignPreviewCompanyColorRequired),
        ),
      );
      setState(() => _isApplying = false);
      return;
    }

    final theme = widget.card.theme.copyWith(
      proDesignId: widget.template.id,
      useCompanyColors: useCompanyColors,
      brandColor: useCompanyColors ? brandHex : null,
      clearBrandColor: !useCompanyColors,
    );

    final previousCard = widget.card;
    cardsProvider.replaceCard(previousCard.copyWith(theme: theme));

    try {
      final updated = await cardsApi.updateCardTheme(previousCard.id, theme);
      cardsProvider.replaceCard(updated);
      if (!mounted) return;
      await persistUserWorkspace(context);
      if (!mounted) return;
      navigator.pop();
      final l10n = context.l10n;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.proDesignPreviewApplied(widget.template.name))),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      cardsProvider.replaceCard(previousCard);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      cardsProvider.replaceCard(previousCard);
      final l10n = context.l10n;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.proDesignPreviewApplyError),
        ),
      );
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final card = widget.card;
    final usesColoredChrome = template.usesColoredChrome;
    final isLight = template.usesLightSurface;

    final chromeColor = usesColoredChrome
        ? AppColors.onPrimary
        : (isLight ? AppColors.textPrimary : AppColors.onPrimary);
    final chromeMuted = usesColoredChrome
        ? AppColors.onPrimary.withValues(alpha: 0.9)
        : (isLight
            ? AppColors.textSecondary
            : AppColors.onPrimary.withValues(alpha: 0.9));
    final pillBackground = usesColoredChrome
        ? Colors.black.withValues(alpha: 0.22)
        : (isLight
            ? AppColors.inputFill
            : AppColors.onPrimary.withValues(alpha: 0.14));
    final pillBorder = usesColoredChrome
        ? Colors.transparent
        : (isLight
            ? AppColors.border
            : AppColors.onPrimary.withValues(alpha: 0.18));

    final scaffoldColor = switch (template.layout) {
      ProDesignLayout.degradeNoir => ProDesignTemplate.degradeNoirBlack,
      ProDesignLayout.bubble => AppColors.background,
      ProDesignLayout.arc => template.background,
      ProDesignLayout.or => template.background,
      _ => template.background,
    };

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: template.gradientEnd != null && !isLight
          ? DecoratedBox(
              decoration: template.backgroundDecoration,
              child: _buildBody(
                context,
                template: template,
                card: card,
                chromeColor: chromeColor,
                chromeMuted: chromeMuted,
                pillBackground: pillBackground,
                pillBorder: pillBorder,
                isLight: isLight,
              ),
            )
          : _buildBody(
              context,
              template: template,
              card: card,
              chromeColor: chromeColor,
              chromeMuted: chromeMuted,
              pillBackground: pillBackground,
              pillBorder: pillBorder,
              isLight: isLight,
            ),
    );
  }

  String? _logoUrl(BuildContext context, BusinessCard card) {
    if (!card.isProfessional) return null;
    return card.companyLogoImageUrl(context.read<TeamsProvider>().myTeam);
  }

  String _avatarInitials(BuildContext context, BusinessCard card) {
    if (!card.isProfessional) return card.initials;
    final team = context.read<TeamsProvider>().myTeam;
    return team?.initials ?? card.companyInitials ?? card.initials;
  }

  Widget _buildBody(
    BuildContext context, {
    required ProDesignTemplate template,
    required BusinessCard card,
    required Color chromeColor,
    required Color chromeMuted,
    required Color pillBackground,
    required Color pillBorder,
    required bool isLight,
  }) {
    final l10n = context.l10n;
    final isBubble = template.usesBubbleHeader;
    final isArc = template.usesArcLayout;
    final logoUrl = _logoUrl(context, card);
    final avatarUrl = card.avatarImageUrl;
    final avatarInitials = _avatarInitials(context, card);

    if (isBubble) {
      return Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
              child: BubbleHeaderSection(
                themeColor: template.themeColor,
                initials: avatarInitials,
                avatarUrl: avatarUrl,
                logoUrl: logoUrl,
                topInset: MediaQuery.paddingOf(context).top,
                topBar: _buildColoredChromeToolbar(
                  context,
                  chromeMuted: chromeMuted,
                  pillBackground: pillBackground,
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        context.screenPadding.left,
                        0,
                        context.screenPadding.right,
                        AppSpacing.lg,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: context.contentMaxWidth,
                          ),
                          child: ProDesignCanvas(
                            referenceHeight: 720,
                            child: BubbleDesign(
                              template: template,
                              fullName: card.fullName,
                              initials: avatarInitials,
                              subtitle: _subtitle,
                              avatarUrl: avatarUrl,
                              logoUrl: logoUrl,
                              showHeader: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildFooter(
                    context,
                    isLight: isLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (isArc) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                child: ArcDesign(
                  template: template,
                  fullName: card.fullName,
                  initials: avatarInitials,
                  subtitle: _subtitle,
                  avatarUrl: avatarUrl,
                  logoUrl: logoUrl,
                  topInset: MediaQuery.paddingOf(context).top,
                  topBar: _buildColoredChromeToolbar(
                    context,
                    chromeMuted: chromeMuted,
                    pillBackground: pillBackground,
                  ),
                  expand: true,
                ),
              ),
            ),
          ),
          ColoredBox(
            color: template.background,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ArcDesign.sheetMarginHorizontal,
                0,
                ArcDesign.sheetMarginHorizontal,
                0,
              ),
              child: ColoredBox(
                color: AppColors.background,
                child: SafeArea(
                  top: false,
                  child: _buildFooter(
                    context,
                    isLight: true,
                    horizontalPadding: AppSpacing.lg,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final toolbar = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: chromeColor,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: pillBackground,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: pillBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: chromeMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.proDesignPreviewRecipientPreview,
                      style: TextStyle(
                        color: chromeMuted,
                        fontSize: context.rs(13),
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.tune_rounded,
              color: chromeColor,
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          toolbar,
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.screenPadding.left,
                    AppSpacing.md,
                    context.screenPadding.right,
                    AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: context.contentMaxWidth,
                    ),
                    child: Center(
                      child: ProDesignCanvas(
                        child: ProDesignBody(
                          template: template,
                          fullName: card.fullName,
                          initials: avatarInitials,
                          subtitle: _subtitle,
                          companyName: card.company?.trim().isNotEmpty == true
                              ? card.company!.trim()
                              : l10n.setupTeamNameHint,
                          avatarUrl: avatarUrl,
                          logoUrl: logoUrl,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildFooter(
            context,
            isLight: isLight,
          ),
        ],
      ),
    );
  }

  Widget _buildColoredChromeToolbar(
    BuildContext context, {
    required Color chromeMuted,
    required Color pillBackground,
  }) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          _BubbleChromeButton(
            icon: Icons.close_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: pillBackground,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: chromeMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.proDesignPreviewRecipientPreview,
                      style: TextStyle(
                        color: chromeMuted,
                        fontSize: context.rs(13),
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BubbleChromeButton(
            icon: Icons.tune_rounded,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context, {
    required bool isLight,
    double horizontalPadding = AppSpacing.screenHorizontal,
  }) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        AppSpacing.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.responsive(
          mobile: AppSizes.buttonHeight,
          tablet: 56,
          desktop: 56,
        ),
        child: FilledButton.icon(
          onPressed: _isApplying ? null : _applyTemplate,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.bleu_primaire,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor:
                AppColors.bleu_primaire.withValues(alpha: 0.6),
            elevation: isLight ? 0 : 6,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: isLight
                  ? BorderSide.none
                  : BorderSide(
                      color: AppColors.onPrimary.withValues(alpha: 0.25),
                    ),
            ),
          ),
          icon: _isApplying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            l10n.proDesignPreviewUseTemplate,
            style: TextStyle(
              fontSize: context.rs(AppFontSize.md),
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleChromeButton extends StatelessWidget {
  const _BubbleChromeButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
