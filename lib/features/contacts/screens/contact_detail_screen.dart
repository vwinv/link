import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/contacts/models/link_contact.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({required this.contact, super.key});

  final LinkContact contact;

  Future<void> _launchUri(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(BuildContext context) async {
    final phone = contact.phone?.trim();
    if (phone == null || phone.isEmpty) return;
    await _launchUri(Uri(scheme: 'tel', path: phone));
  }

  Future<void> _email(BuildContext context) async {
    final email = contact.email?.trim();
    if (email == null || email.isEmpty) return;
    await _launchUri(Uri(scheme: 'mailto', path: email));
  }

  Future<void> _message(BuildContext context) async {
    final phone = contact.phone?.trim();
    final email = contact.email?.trim();
    if (phone != null && phone.isNotEmpty) {
      await _launchUri(Uri(scheme: 'sms', path: phone));
      return;
    }
    if (email != null && email.isNotEmpty) {
      await _email(context);
      return;
    }
    await _share(context);
  }

  Future<void> _share(BuildContext context) async {
    final l10n = context.l10n;
    final slug = contact.linkedCardSlug?.trim();
    if (slug != null && slug.isNotEmpty) {
      final url = ApiConfig.publicUrl(slug);
      await SharePlatformService.shareRichLink(
        context,
        uri: Uri.parse(url),
        subject: contact.fullName,
      );
      return;
    }

    final lines = <String>[
      contact.fullName,
      if (contact.subtitle.isNotEmpty) contact.subtitle,
      if (contact.phone?.trim().isNotEmpty == true) contact.phone!.trim(),
      if (contact.email?.trim().isNotEmpty == true) contact.email!.trim(),
    ];
    await SharePlatformService.shareText(
      context,
      text: lines.join('\n'),
      subject: contact.fullName,
      clipboardMessage: l10n.contactDetailCopied,
    );
  }

  Future<void> _viewCard(BuildContext context) async {
    final slug = contact.linkedCardSlug?.trim();
    if (slug == null || slug.isEmpty) return;
    await context.push('${RoutePaths.publicCard}/$slug');
  }

  String _sourceLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (contact.source) {
      ContactSource.exchange => l10n.contactDetailSourceExchange,
      ContactSource.aiScan => l10n.contactDetailSourceScan,
    };
  }

  String _valueOrDash(BuildContext context, String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return context.l10n.contactDetailUnavailable;
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final avatarUrl = ApiConfig.resolvePublicAssetUrl(contact.avatarUrl);
    final hasPhone = contact.phone?.trim().isNotEmpty == true;
    final hasEmail = contact.email?.trim().isNotEmpty == true;
    final hasCard = contact.isDropOneContact;
    final addedLabel = contact.createdAt != null
        ? DateFormat.yMMMMd(locale).format(contact.createdAt!.toLocal())
        : (contact.addedAgo.isNotEmpty
            ? contact.addedAgo
            : l10n.contactDetailUnavailable);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: Row(
                children: [
                  const LinkBackButton(),
                  Expanded(
                    child: Text(
                      l10n.contactDetailTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.lg),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl,
                ),
                children: [
                  _SectionCard(
                    child: Column(
                      children: [
                        _ContactAvatar(
                          initials: contact.initials,
                          avatarColor: contact.avatarColor,
                          imageUrl: avatarUrl,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                contact.fullName.isNotEmpty
                                    ? contact.fullName
                                    : l10n.contactDetailUntitled,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: context.rs(AppFontSize.xl),
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            if (contact.source == ContactSource.exchange)
                              const _DropOneBadge()
                            else
                              const _ScanBadge(),
                          ],
                        ),
                        if (contact.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            contact.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.rs(AppFontSize.sm),
                            ),
                          ),
                        ],
                        if (hasCard) ...[
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            height: AppSizes.buttonHeight,
                            child: FilledButton.icon(
                              onPressed: () => _viewCard(context),
                              icon: const Icon(Icons.visibility_outlined),
                              label: Text(l10n.contactDetailViewCard),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.bleu_primaire,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.contactDetailInfoTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.rs(AppFontSize.md),
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _InfoRow(
                          icon: Icons.work_outline_rounded,
                          label: l10n.contactDetailJob,
                          value: _valueOrDash(context, contact.jobTitle),
                        ),
                        _InfoRow(
                          icon: Icons.apartment_rounded,
                          label: l10n.contactDetailCompany,
                          value: _valueOrDash(context, contact.company),
                        ),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: l10n.contactDetailPhone,
                          value: _valueOrDash(context, contact.phone),
                        ),
                        _InfoRow(
                          icon: Icons.mail_outline_rounded,
                          label: l10n.contactDetailEmail,
                          value: _valueOrDash(context, contact.email),
                        ),
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: l10n.contactDetailSource,
                          value: _sourceLabel(context),
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: l10n.contactDetailAddedAt,
                          value: addedLabel,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.contactDetailActionsTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.rs(AppFontSize.md),
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (hasPhone) ...[
                          _ActionTile(
                            icon: Icons.phone_outlined,
                            title: l10n.contactDetailCall,
                            onTap: () => _call(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _ActionTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: l10n.contactDetailSendMessage,
                            onTap: () => _message(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (hasEmail) ...[
                          _ActionTile(
                            icon: Icons.mail_outline_rounded,
                            title: l10n.contactDetailSendEmail,
                            onTap: () => _email(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        _ActionTile(
                          icon: Icons.share_outlined,
                          title: l10n.contactDetailShare,
                          onTap: () => _share(context),
                        ),
                      ],
                    ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFEDEDF0)),
      ),
      child: child,
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.initials,
    required this.avatarColor,
    this.imageUrl,
  });

  final String initials;
  final Color avatarColor;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: 44,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontWeight: AppFontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }
}

class _DropOneBadge extends StatelessWidget {
  const _DropOneBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF1B7A45)),
          const SizedBox(width: 4),
          Text(
            context.l10n.cardVisitorsFilterDropOne,
            style: TextStyle(
              color: const Color(0xFF1B7A45),
              fontSize: context.rs(12),
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanBadge extends StatelessWidget {
  const _ScanBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bleu_clair,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.document_scanner_outlined,
            size: 14,
            color: AppColors.bleu_primaire,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.contactDetailSourceScan,
            style: TextStyle(
              color: AppColors.bleu_primaire,
              fontSize: context.rs(12),
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textTertiaire),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.rs(AppFontSize.sm),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(AppFontSize.sm),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.8),
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(AppFontSize.md),
                    fontWeight: AppFontWeight.medium,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaire,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
