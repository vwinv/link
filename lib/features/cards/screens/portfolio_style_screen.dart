import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/data/portfolio_style_catalog.dart';
import 'package:linkflutter/features/cards/screens/portfolio_editor_screen.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/portfolio_style.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/sharing/screens/public_portfolio_screen.dart';
import 'package:linkflutter/features/cards/widgets/portfolio_layout_thumb.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:provider/provider.dart';

class PortfolioStyleScreen extends StatefulWidget {
  const PortfolioStyleScreen({
    required this.card,
    this.customizeOnly = false,
    super.key,
  });

  final BusinessCard card;

  /// Personnaliser : Choisir ouvre l’aperçu, Enregistrer est sur l’aperçu.
  final bool customizeOnly;

  @override
  State<PortfolioStyleScreen> createState() => _PortfolioStyleScreenState();
}

class _PortfolioStyleScreenState extends State<PortfolioStyleScreen> {
  String _layoutId = PortfolioStyle.defaults.layoutId;
  String _colorId = PortfolioStyle.defaults.colorId;
  var _loading = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final style = await context
          .read<CardsApiService>()
          .fetchPortfolioStyle(widget.card.id);
      if (!mounted) return;
      setState(() {
        _layoutId = PortfolioStyleCatalog.layoutById(style.layoutId).id;
        _colorId = PortfolioStyleCatalog.colorById(style.colorId).id;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<bool> _persistStyle() async {
    await context.read<CardsApiService>().savePortfolioStyle(
          cardId: widget.card.id,
          layoutId: _layoutId,
          colorId: _colorId,
        );
    return true;
  }

  Future<void> _openThemedPreview({bool canSaveStyle = false}) async {
    if (!mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PublicPortfolioScreen(
          slug: widget.card.slug,
          layout: _layoutId,
          color: _colorId,
          cardId: canSaveStyle ? widget.card.id : null,
          canSaveStyle: canSaveStyle,
        ),
      ),
    );
    if (saved == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _preview() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _persistStyle();
      if (!mounted) return;
      setState(() => _saving = false);
      await _openThemedPreview();
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 403) {
        await openLinkPremium(
          context,
          preferredAudience: OfferAudience.portfolio,
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.portfolioStyleSaveError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _choose() async {
    await _openThemedPreview(canSaveStyle: true);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _persistStyle();
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PortfolioEditorScreen(
            card: widget.card,
            layoutId: _layoutId,
            colorId: _colorId,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 403) {
        await openLinkPremium(
          context,
          preferredAudience: OfferAudience.portfolio,
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.portfolioStyleSaveError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = PortfolioStyleCatalog.colorById(_colorId);
    final layout = PortfolioStyleCatalog.layoutById(_layoutId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  widget.customizeOnly
                      ? const LinkBackButton()
                      : Row(
                          children: [
                            const Expanded(child: LinkBackButton()),
                            OutlinedButton(
                              onPressed: _loading || _saving ? null : _preview,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.bleu_primaire,
                                side: const BorderSide(color: Color(0xFFD7E4FF)),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(l10n.portfolioEditorPreview),
                            ),
                          ],
                        ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.portfolioStyleTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(AppFontSize.xxl),
                      fontWeight: AppFontWeight.bold,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.portfolioStyleSubtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.rs(15),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text(
                        l10n.portfolioStyleColor,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(12),
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        color.name(l10n),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.rs(15),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ColorPalette(
                    selectedId: _colorId,
                    onSelected: (id) => setState(() => _colorId = id),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.portfolioStyleModels,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.rs(12),
                      fontWeight: AppFontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: PortfolioStyleCatalog.layouts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final option = PortfolioStyleCatalog.layouts[index];
                        return _LayoutCard(
                          name: option.name(l10n),
                          hint: option.hint(l10n),
                          selected: option.id == _layoutId,
                          thumb: PortfolioLayoutThumb(
                            layoutId: option.id,
                            color: color,
                            avatarUrl: widget.card.avatarImageUrl,
                          ),
                          onTap: () => setState(() => _layoutId = option.id),
                        );
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: LinkPrimaryButton(
                label: widget.customizeOnly
                    ? l10n.portfolioStyleChoose(
                        layout.name(l10n),
                        color.name(l10n),
                      )
                    : l10n.portfolioStyleContinue(
                        layout.name(l10n),
                        color.name(l10n),
                      ),
                borderRadius: 28,
                isLoading: _saving,
                onPressed: _loading
                    ? null
                    : (widget.customizeOnly ? _choose : _save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.name,
    required this.hint,
    required this.selected,
    required this.thumb,
    required this.onTap,
  });

  final String name;
  final String hint;
  final bool selected;
  final Widget thumb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.bleu_primaire : const Color(0xFFE7E8EE),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: thumb,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: context.rs(15),
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.rs(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      const _CheckBadge(),
                    ],
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

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.bleu_primaire,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.onPrimary, size: 15),
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 6;
        const gap = 12.0;
        final size = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [
            for (final option in PortfolioStyleCatalog.colors)
              SizedBox(
                width: size,
                height: size,
                child: _ColorSwatch(
                  option: option,
                  selected: option.id == selectedId,
                  onTap: () => onSelected(option.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PortfolioColorOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.bleu_primaire : Colors.transparent,
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: option.swatchGradient == null ? option.swatch : null,
            gradient: option.swatchGradient,
          ),
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  color: option.isLight ? AppColors.textPrimary : AppColors.onPrimary,
                  size: 18,
                )
              : null,
        ),
      ),
    );
  }
}
