import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/color_utils.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/data/pro_design_catalog.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_theme_settings.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/brand_color_picker_sheet.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_grid_card.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:provider/provider.dart';

enum _CardScope { personal, professional }

extension on _CardScope {
  CardKind get toCardKind =>
      this == _CardScope.personal ? CardKind.personal : CardKind.professional;
}

class ProfessionalDesignsScreen extends StatefulWidget {
  const ProfessionalDesignsScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<ProfessionalDesignsScreen> createState() =>
      _ProfessionalDesignsScreenState();
}

class _ProfessionalDesignsScreenState extends State<ProfessionalDesignsScreen> {
  static const _defaultBrandColors = [
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFBA68C8),
    Color(0xFFFFB74D),
    Color(0xFFB0BEC5),
  ];

  _CardScope _scope = _CardScope.professional;
  var _isCreatingProfessional = false;
  var _useCompanyColors = false;
  var _selectedColorIndex = 0;
  late List<Color> _brandColors;
  final _colorScrollController = ScrollController();
  String? _syncedThemeKey;

  @override
  void dispose() {
    _colorScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _brandColors = List<Color>.of(_defaultBrandColors);
    _scope = widget.card.kind.isProfessional
        ? _CardScope.professional
        : _CardScope.personal;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clampScopeToEntitlements();
      _bootstrapColorPreferences();
    });
  }

  String _themeSyncKey(CardThemeSettings theme) =>
      '${theme.useCompanyColors}|${theme.brandColor ?? ''}';

  void _applyThemeToUiState(
    CardThemeSettings theme, {
    Color? teamColor,
  }) {
    _useCompanyColors = theme.useCompanyColors;
    final savedBrand = theme.brandColorValue;

    if (savedBrand != null) {
      _brandColors = _colorsWithTeamFirst(savedBrand);
      final index = _brandColors.indexWhere((color) => _sameRgb(color, savedBrand));
      _selectedColorIndex = index >= 0 ? index : 0;
      return;
    }

    if (teamColor != null && _scope == _CardScope.professional) {
      _brandColors = _colorsWithTeamFirst(teamColor);
      _selectedColorIndex = 0;
    }
  }

  bool _applySyncFromCard(BusinessCard card) {
    final key = _themeSyncKey(card.theme);
    if (_syncedThemeKey == key) return false;

    _syncedThemeKey = key;
    final teamColor = context.read<TeamsProvider>().myTeam?.brandColorValue;
    _applyThemeToUiState(card.theme, teamColor: teamColor);
    return true;
  }

  void _syncColorPreferencesFromCard(BusinessCard card, {bool scroll = false}) {
    if (!_applySyncFromCard(card)) return;
    setState(() {});
    if (scroll) _scrollToSelectedColor();
  }

  void _scheduleSyncFromCard(BusinessCard card) {
    final key = _themeSyncKey(card.theme);
    if (_syncedThemeKey == key) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncColorPreferencesFromCard(card, scroll: true);
    });
  }

  void _clampScopeToEntitlements() {
    if (_scope != _CardScope.professional) return;
    if (context.read<SubscriptionsProvider>().hasTeamSubscription) return;
    setState(() => _scope = _CardScope.personal);
  }

  Future<void> _bootstrapColorPreferences() async {
    if (!mounted) return;

    final teamsProvider = context.read<TeamsProvider>();
    if (!teamsProvider.hasLoaded) {
      await teamsProvider.load();
      if (!mounted) return;
    }

    final card = _liveCard(context.read<CardsProvider>());
    setState(() => _applySyncFromCard(card));
    _scrollToSelectedColor();
  }

  void _scrollToSelectedColor() {
    if (!_useCompanyColors) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_colorScrollController.hasClients) return;

      const swatchStride = 34.0 + AppSpacing.sm;
      final target = (_selectedColorIndex * swatchStride).clamp(
        0.0,
        _colorScrollController.position.maxScrollExtent,
      );

      _colorScrollController.animateTo(
        target,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
      );
    });
  }

  static bool _sameRgb(Color a, Color b) =>
      (a.toARGB32() & 0xFFFFFF) == (b.toARGB32() & 0xFFFFFF);

  List<Color> _colorsWithTeamFirst(Color teamColor) {
    final colors = List<Color>.of(_defaultBrandColors);
    colors.removeWhere((color) => _sameRgb(color, teamColor));
    return [teamColor, ...colors];
  }

  void _onCompanyColorsToggle(bool value) {
    setState(() {
      _useCompanyColors = value;
      if (!value) return;

      final teamColor = context.read<TeamsProvider>().myTeam?.brandColorValue;
      if (teamColor == null) return;

      final teamIndex = _brandColors.indexWhere(
        (color) => _sameRgb(color, teamColor),
      );
      if (teamIndex >= 0) {
        _selectedColorIndex = teamIndex;
      }
    });
    if (value) _scrollToSelectedColor();
  }

  void _onBrandColorSelected(int index) {
    setState(() {
      _selectedColorIndex = index;
      _useCompanyColors = true;
    });
    _scrollToSelectedColor();
  }

  String get _templatesGridKey =>
      'templates-${_effectiveUseCompanyColors ? 1 : 0}-${_activeBrandColor.toARGB32()}';

  bool get _showCompanyColors => _scope == _CardScope.professional;

  bool get _effectiveUseCompanyColors =>
      _showCompanyColors && _useCompanyColors;

  Color get _activeBrandColor => _brandColors[_selectedColorIndex];

  Future<void> _openColorPicker(BuildContext anchorContext) async {
    final box = anchorContext.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;

    final picked = await showBrandColorPicker(
      context,
      anchor: anchor,
      initialColor: _activeBrandColor,
    );
    if (picked == null || !mounted) return;
    if (picked == Colors.transparent) return;

    setState(() {
      final existingIndex = _brandColors.indexWhere(
        (color) => color.toARGB32() == picked.toARGB32(),
      );
      if (existingIndex >= 0) {
        _selectedColorIndex = existingIndex;
      } else {
        _brandColors.add(picked);
        _selectedColorIndex = _brandColors.length - 1;
      }
      _useCompanyColors = true;
    });
  }

  List<ProDesignTemplate> get _visibleTemplates {
    if (!_effectiveUseCompanyColors) return ProDesignCatalog.templates;
    return ProDesignCatalog.withBrandColor(_activeBrandColor);
  }

  bool _isActiveDesign(ProDesignTemplate template, String? proDesignId) {
    if (proDesignId == null) return false;
    return ProDesignCatalog.byId(proDesignId)?.id == template.id;
  }

  BusinessCard _liveCard(CardsProvider cardsProvider) {
    final scoped = cardsProvider.cardForKind(_scope.toCardKind);
    if (scoped != null) return scoped;

    for (final item in cardsProvider.cards) {
      if (item.id == widget.card.id) return item;
    }
    return widget.card;
  }

  Future<void> _ensureScopedCard() async {
    if (_scope != _CardScope.professional || _isCreatingProfessional) return;

    final cardsProvider = context.read<CardsProvider>();
    if (cardsProvider.professionalCard != null) return;

    setState(() => _isCreatingProfessional = true);
    try {
      final created = await openSetupProfessionalTeam(context);
      if (mounted && created != null) setState(() {});
    } finally {
      if (mounted) setState(() => _isCreatingProfessional = false);
    }
  }

  Future<void> _onScopeChanged(_CardScope scope) async {
    if (scope == _scope) return;

    if (scope == _CardScope.professional) {
      final professionalCard = context.read<CardsProvider>().professionalCard;
      if (professionalCard != null) {
        if (!await ensureCanCustomizeCard(context, professionalCard)) return;
      } else if (!await ensureTeamSubscription(context)) {
        return;
      }
      if (!mounted) return;
    }

    setState(() {
      _scope = scope;
      _syncedThemeKey = null;
    });

    final card = _liveCard(context.read<CardsProvider>());
    _syncColorPreferencesFromCard(card, scroll: true);

    if (scope == _CardScope.professional) {
      await _ensureScopedCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final card = _liveCard(context.watch<CardsProvider>());
    _scheduleSyncFromCard(card);
    final subscriptions = context.watch<SubscriptionsProvider>();
    final hasTeamSubscription = subscriptions.hasTeamSubscription;
    final hidePremium = subscriptions.hidePremiumUpsells;
    final team = context.watch<TeamsProvider>().myTeam;
    final useTeamBranding = _scope == _CardScope.professional;
    final logoUrl =
        useTeamBranding ? card.companyLogoImageUrl(team) : null;
    final avatarUrl = card.avatarImageUrl;
    final avatarInitials = useTeamBranding
        ? (team?.initials ?? card.companyInitials ?? card.initials)
        : card.initials;
    final companyName = card.company?.trim().isNotEmpty == true
        ? card.company!.trim()
        : l10n.setupTeamNameHint;
    final missingProfessional =
        _scope == _CardScope.professional && card.kind.isPersonal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: const LinkBackButton(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: context.screenPadding.copyWith(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xl,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.customizeProDesigns,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: context.rs(28),
                                  fontWeight: AppFontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.proDesignsSubtitle(
                                  ProDesignCatalog.templates.length,
                                ),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: context.rs(AppFontSize.md),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!hidePremium) const _PremiumBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionLabel(l10n.proDesignsCardTypeSection),
                    const SizedBox(height: AppSpacing.md),
                    _CardScopeToggle(
                      scope: _scope,
                      professionalLocked: !hasTeamSubscription,
                      onChanged: _onScopeChanged,
                    ),
                    if (missingProfessional) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _isCreatingProfessional
                            ? l10n.proDesignsConfiguringTeam
                            : l10n.proDesignsOpenTeamSetup,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.sm),
                        ),
                      ),
                    ] else ...[
                      if (_showCompanyColors) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _CompanyColorsCard(
                          value: _useCompanyColors,
                          selectedColor: _activeBrandColor,
                          colors: _brandColors,
                          selectedIndex: _selectedColorIndex,
                          colorScrollController: _colorScrollController,
                          onToggle: _onCompanyColorsToggle,
                          onColorSelected: _onBrandColorSelected,
                          onAddColor: _openColorPicker,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      _SectionLabel(
                        l10n.proDesignsTemplatesSection(_visibleTemplates.length),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GridView.builder(
                        key: ValueKey(_templatesGridKey),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _visibleTemplates.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(
                            mobile: 2,
                            tablet: 3,
                            desktop: 3,
                          ),
                          mainAxisSpacing: AppSpacing.lg,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: context.responsive(
                            mobile: 0.55,
                            tablet: 0.58,
                            desktop: 0.62,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final template = _visibleTemplates[index];
                          return _ProDesignGridTile(
                            key: ValueKey(
                              '$_templatesGridKey-${template.id}',
                            ),
                            template: template,
                            fullName: card.fullName,
                            initials: avatarInitials,
                            subtitle: card.subtitle.isNotEmpty
                                ? card.subtitle
                                : companyName,
                            companyName: companyName,
                            address: card.address?.trim(),
                            avatarUrl: avatarUrl,
                            logoUrl: logoUrl,
                            isActiveDesign: _isActiveDesign(
                              template,
                              card.theme.proDesignId,
                            ),
                            onOpen: () async {
                              await openProDesignPreview(
                                context,
                                card: card,
                                template: template,
                                useCompanyColors: _effectiveUseCompanyColors,
                                companyColorHex: _effectiveUseCompanyColors
                                    ? colorToHex(_activeBrandColor)
                                    : null,
                              );
                              if (!context.mounted) return;
                              final updated =
                                  _liveCard(context.read<CardsProvider>());
                              _syncColorPreferencesFromCard(updated, scroll: true);
                            },
                          );
                        },
                      ),
                    ],
                  ],
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

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.or, size: 16),
          const SizedBox(width: 6),
          Text(
            l10n.premiumBadge,
            style: const TextStyle(
              color: AppColors.or,
              fontSize: 12,
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardScopeToggle extends StatelessWidget {
  const _CardScopeToggle({
    required this.scope,
    required this.onChanged,
    this.professionalLocked = false,
  });

  final _CardScope scope;
  final ValueChanged<_CardScope> onChanged;
  final bool professionalLocked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScopeOption(
              label: l10n.cardScopePersonal,
              icon: Icons.person_outline_rounded,
              isSelected: scope == _CardScope.personal,
              onTap: () => onChanged(_CardScope.personal),
            ),
          ),
          Expanded(
            child: _ScopeOption(
              label: l10n.cardScopeProfessional,
              icon: Icons.groups_outlined,
              isSelected: scope == _CardScope.professional,
              isLocked: professionalLocked,
              onTap: () => onChanged(_CardScope.professional),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeOption extends StatelessWidget {
  const _ScopeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isLocked = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.bleu_primaire : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontSize: context.rs(AppFontSize.sm),
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyColorsCard extends StatelessWidget {
  const _CompanyColorsCard({
    required this.value,
    required this.selectedColor,
    required this.colors,
    required this.selectedIndex,
    required this.onToggle,
    required this.onColorSelected,
    required this.onAddColor,
    this.colorScrollController,
  });

  final bool value;
  final Color selectedColor;
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onColorSelected;
  final void Function(BuildContext anchorContext) onAddColor;
  final ScrollController? colorScrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.proDesignsCompanyColors,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.proDesignsCompanyColorsSubtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(AppFontSize.sm),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onToggle,
                activeTrackColor: AppColors.success,
                activeThumbColor: AppColors.onPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedOpacity(
            opacity: value ? 1 : 0.45,
            duration: AppDurations.fast,
            child: IgnorePointer(
              ignoring: !value,
              child: Row(
                children: [
                  _AddColorButton(color: selectedColor, onTap: onAddColor),
                  const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: colorScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                        children: [
                          for (var i = 0; i < colors.length; i++) ...[
                            _ColorSwatch(
                              color: colors[i],
                              isSelected: selectedIndex == i,
                              onTap: () => onColorSelected(i),
                            ),
                            if (i < colors.length - 1)
                              const SizedBox(width: AppSpacing.sm),
                          ],
                          const SizedBox(width: AppSpacing.sm),
                          _RainbowAddButton(onTap: onAddColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddColorButton extends StatelessWidget {
  const _AddColorButton({required this.color, required this.onTap});

  final Color color;
  final void Function(BuildContext anchorContext) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        padding: EdgeInsets.all(isSelected ? 3 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 2)
              : null,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _RainbowAddButton extends StatelessWidget {
  const _RainbowAddButton({required this.onTap});

  final void Function(BuildContext anchorContext) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              Color(0xFFFF5252),
              Color(0xFFFFEB3B),
              Color(0xFF4CAF50),
              Color(0xFF2196F3),
              Color(0xFFFF5252),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProDesignGridTile extends StatelessWidget {
  const _ProDesignGridTile({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    required this.companyName,
    this.address,
    required this.isActiveDesign,
    required this.onOpen,
    this.avatarUrl,
    this.logoUrl,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String companyName;
  final String? address;
  final String? avatarUrl;
  final String? logoUrl;
  final bool isActiveDesign;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ProDesignGridCard(
      template: template,
      fullName: fullName,
      initials: initials,
      subtitle: subtitle,
      companyName: companyName,
      address: address,
      avatarUrl: avatarUrl,
      logoUrl: logoUrl,
      isActiveDesign: isActiveDesign,
      onOpen: onOpen,
    );
  }
}
