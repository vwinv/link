import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletPassPreview extends StatelessWidget {
  const WalletPassPreview({
    required this.card,
    super.key,
    this.companyLogoUrl,
    this.onLinkTap,
  });

  final BusinessCard card;
  final String? companyLogoUrl;
  final VoidCallback? onLinkTap;

  String get _companyLabel {
    final company = card.company?.trim() ?? '';
    return company.isNotEmpty ? company : 'DropOne';
  }

  String get _companyInitials {
    final company = card.company?.trim() ?? '';
    if (company.isEmpty) return 'LK';
    final parts = company.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get _roleLabel {
    final job = card.jobTitle?.trim() ?? '';
    return job.isNotEmpty ? job : card.subtitle;
  }

  Widget _buildPortrait() {
    final url = card.avatarImageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsPortrait(),
      );
    }
    return _initialsPortrait();
  }

  Widget _initialsPortrait() {
    return Center(
      child: Text(
        card.initials,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: AppFontSize.lg,
          fontWeight: AppFontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2E)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                _CompanyLogo(
                  logoUrl: companyLogoUrl,
                  initials: _companyInitials,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _companyLabel,
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: AppFontSize.sm,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                ),
                Material(
                  color: AppColors.bleu_primaire,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onLinkTap,
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.link_rounded,
                        color: AppColors.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.bleu_primaire,
                    shape: BoxShape.circle,
                  ),
                  child: _buildPortrait(),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.fullName,
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: AppFontSize.lg,
                          fontWeight: AppFontWeight.bold,
                        ),
                      ),
                      if (_roleLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _roleLabel,
                          style: const TextStyle(
                            color: AppColors.textTertiaire,
                            fontSize: AppFontSize.sm,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.xxl,
            ),
            child: Center(
              child: QrImageView(
                data: ShareCardHelper.publicUrl(card.slug),
                size: 132,
                backgroundColor: AppColors.onPrimary,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.textPrimary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({
    required this.initials,
    this.logoUrl,
  });

  final String? logoUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    final hasLogo = url != null && url.isNotEmpty;

    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.onPrimary,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasLogo
          ? Image.network(
              url,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _InitialsFallback(initials: initials),
            )
          : _InitialsFallback(initials: initials),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: const TextStyle(
        color: AppColors.bleu_primaire,
        fontSize: 10,
        fontWeight: AppFontWeight.bold,
      ),
    );
  }
}
