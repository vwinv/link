import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/cards/models/card_badge_type.dart';
import 'package:linkflutter/features/cards/models/card_style.dart';
import 'package:linkflutter/features/cards/widgets/card_qr_display.dart';

class CardPreview extends StatelessWidget {
  const CardPreview({
    required this.fullName,
    required this.initials,
    required this.email,
    super.key,
    this.subtitle,
    this.phone,
    this.address,
    this.tagLabel = 'Carte perso',
    this.borderRadius = AppRadius.xl,
    this.style = CardStyle.noir,
    this.showQr = true,
    this.qrData,
    this.avatarUrl,
    this.companyLogoUrl,
    this.cardBadge = CardBadgeType.personalTag,
    this.avatarOnRight = false,
    this.avatarSize = 48,
    this.showDropOneLogo = false,
  });

  static const _placeholder = 'xxxxxxx';

  final String fullName;
  final String initials;
  final String email;
  final String? subtitle;
  final String? phone;
  final String? address;
  final String tagLabel;
  final double borderRadius;
  final CardStyle style;
  final bool showQr;
  final String? qrData;
  final String? avatarUrl;
  final String? companyLogoUrl;
  final CardBadgeType cardBadge;
  final bool avatarOnRight;
  final double avatarSize;
  final bool showDropOneLogo;

  bool get _showsCompanyLogo => cardBadge == CardBadgeType.companyLogo;

  String _display(String? value) {
    if (value == null || value.trim().isEmpty) return _placeholder;
    return value.trim();
  }

  String _displayInitials(String value) {
    if (value.trim().isEmpty) return 'XX';
    return value.trim();
  }

  Color get _primaryText =>
      style.lightTheme ? AppColors.textPrimary : AppColors.onPrimary;

  Color get _secondaryText => style.lightTheme
      ? const Color.fromARGB(255, 79, 79, 80)
      : const Color.fromARGB(255, 221, 221, 221);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: style.accent.withValues(alpha: style.lightTheme ? 0.25 : 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: style.accent.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (avatarOnRight) ...[
                _LeadingBrandMark(
                  logoUrl: companyLogoUrl,
                  useDropOne: showDropOneLogo,
                ),
                const SizedBox(width: AppSpacing.md),
              ] else ...[
                _avatarChip(),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _display(fullName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: AppFontSize.md,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _display(subtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                    if ((address ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        address!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: AppFontSize.sm,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (avatarOnRight) ...[
                const SizedBox(width: AppSpacing.sm),
                _avatarChip(),
              ] else if (_showsCompanyLogo) ...[
                const SizedBox(width: AppSpacing.sm),
                _CompanyLogoMark(logoUrl: companyLogoUrl),
              ] else ...[
                const SizedBox(width: AppSpacing.sm),
                _CardBadge(
                  tagLabel: tagLabel,
                  secondaryTextColor: _secondaryText,
                  lightTheme: style.lightTheme,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            thickness: 1,
            color: style.lightTheme
                ? const Color(0xFFE5E5EA)
                : const Color(0xFF2A2A2E),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactRow(
                      icon: Icons.mail_outline_rounded,
                      label: _display(email),
                      color: _secondaryText,
                      textColor: _primaryText,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      label: _display(phone),
                      color: _secondaryText,
                      textColor: _primaryText,
                    ),
                    if ((address ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _ContactRow(
                        icon: Icons.location_on_outlined,
                        label: address!.trim(),
                        color: _secondaryText,
                        textColor: _primaryText,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              if (showQr) ...[
                const SizedBox(width: AppSpacing.md),
                if (qrData != null)
                  CardQrDisplay(
                    data: qrData!,
                    size: 56,
                    padding: 6,
                    dotColor: style.accent,
                  )
                else
                  _QrPreview(accentColor: style.accent),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarChip() {
    return ClipOval(
      child: Container(
        width: avatarSize,
        height: avatarSize,
        color: style.accent,
        alignment: Alignment.center,
        child: _buildAvatar(),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsAvatar(),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Text(
      _displayInitials(initials),
      style: const TextStyle(
        color: AppColors.onPrimary,
        fontSize: AppFontSize.sm,
        fontWeight: AppFontWeight.bold,
      ),
    );
  }
}

class _LeadingBrandMark extends StatelessWidget {
  const _LeadingBrandMark({
    this.logoUrl,
    this.useDropOne = false,
  });

  final String? logoUrl;
  final bool useDropOne;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    final hasNetwork = url != null && url.isNotEmpty;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasNetwork
          ? Image.network(
              url,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => useDropOne
                  ? Image.asset(AppAssets.icone, width: 40, height: 40)
                  : const Icon(
                      Icons.business_rounded,
                      size: 20,
                      color: AppColors.textTertiaire,
                    ),
            )
          : useDropOne
              ? Image.asset(
                  AppAssets.icone,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  Icons.business_rounded,
                  size: 20,
                  color: AppColors.textTertiaire,
                ),
    );
  }
}

class _CompanyLogoMark extends StatelessWidget {
  const _CompanyLogoMark({this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    final hasLogo = url != null && url.isNotEmpty;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Image.network(
              url,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.business_rounded,
                size: 18,
                color: AppColors.textTertiaire,
              ),
            )
          : const Icon(
              Icons.business_rounded,
              size: 18,
              color: AppColors.textTertiaire,
            ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({
    required this.tagLabel,
    required this.secondaryTextColor,
    required this.lightTheme,
  });

  final String tagLabel;
  final Color secondaryTextColor;
  final bool lightTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: lightTheme ? const Color(0xFFE5E5EA) : const Color(0xFF2A2A2E),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        tagLabel,
        style: TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: AppFontWeight.medium,
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontSize: AppFontSize.sm),
          ),
        ),
      ],
    );
  }
}

class _QrPreview extends StatelessWidget {
  const _QrPreview({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 25,
        itemBuilder: (context, index) {
          const filled = {0, 1, 2, 4, 5, 6, 10, 12, 14, 18, 20, 22, 24};
          return DecoratedBox(
            decoration: BoxDecoration(
              color: filled.contains(index) ? accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        },
      ),
    );
  }
}
