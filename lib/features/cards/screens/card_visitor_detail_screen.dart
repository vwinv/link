import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_visitors.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:provider/provider.dart';

abstract final class _D {
  static const bg = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E5EA);
  static const actionBg = Color(0xFFF2F2F7);
  static const meta = Color(0xFF8E8E93);
  static const label = Color(0xFF6C6C70);
  static const blue = Color(0xFF0A6BFF);
  static const blueSoft = Color(0xFFE8F0FF);
  static const dropOneBg = Color(0xFFE6F9F3);
  static const dropOneFg = Color(0xFF1B7A45);
  static const guestBg = Color(0xFFE8F0FF);
  static const guestFg = Color(0xFF0A6BFF);
  static const yes = Color(0xFF16A34A);
  static const no = Color(0xFFE53935);
}

class CardVisitorDetailScreen extends StatefulWidget {
  const CardVisitorDetailScreen({
    required this.card,
    required this.visitor,
    super.key,
  });

  final BusinessCard card;
  final CardVisitor visitor;

  @override
  State<CardVisitorDetailScreen> createState() =>
      _CardVisitorDetailScreenState();
}

class _CardVisitorDetailScreenState extends State<CardVisitorDetailScreen> {
  var _isAddingContact = false;

  CardVisitor get visitor => widget.visitor;
  bool get _isDropOne => visitor.isDropOneUser;

  String _sourceLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (visitor.source) {
      'qr' => l10n.cardVisitorDetailMethodQr,
      'nfc' => l10n.cardVisitorDetailMethodNfc,
      'share' => l10n.cardVisitorDetailMethodShare,
      'app' => l10n.cardVisitorDetailMethodApp,
      _ => l10n.cardVisitorDetailMethodLink,
    };
  }

  IconData get _sourceIcon => switch (visitor.source) {
        'qr' => Icons.qr_code_2_rounded,
        'nfc' => Icons.nfc_rounded,
        'share' => Icons.reply_rounded,
        'app' => Icons.phone_iphone_rounded,
        _ => Icons.link_rounded,
      };

  String _formatDuration(BuildContext context) {
    final seconds = visitor.durationSeconds;
    if (seconds == null || seconds <= 0) {
      return context.l10n.cardVisitorDetailUnavailable;
    }
    final minutes = seconds ~/ 60;
    final rem = seconds % 60;
    if (minutes <= 0) {
      return context.l10n.cardVisitorDetailDurationSeconds(rem);
    }
    return context.l10n.cardVisitorDetailDurationMinutes(minutes, rem);
  }

  Future<void> _invite() async {
    final l10n = context.l10n;
    final message = l10n.cardVisitorDetailInviteShareText(
      ApiConfig.appStoreUrl,
      ApiConfig.playStoreUrl,
      ApiConfig.publicUrl(widget.card.slug),
    );
    await SharePlatformService.shareWhatsApp(context, url: message);
  }

  Future<void> _sendMessage() async {
    final l10n = context.l10n;
    if (_isDropOne && visitor.viewerCardSlug != null) {
      final url = ApiConfig.publicUrl(visitor.viewerCardSlug!);
      await SharePlatformService.shareText(
        context,
        text: l10n.cardVisitorDetailMessageShareText(visitor.displayName, url),
      );
      return;
    }
    await _invite();
  }

  Future<void> _shareProfile() async {
    if (_isDropOne && visitor.viewerCardSlug != null) {
      final url = ApiConfig.publicUrl(visitor.viewerCardSlug!);
      await SharePlatformService.shareRichLink(
        context,
        uri: Uri.parse(url),
        subject: visitor.displayName,
      );
      return;
    }
    await _invite();
  }

  Future<void> _viewCard() async {
    final slug = visitor.viewerCardSlug?.trim();
    if (slug == null || slug.isEmpty) return;
    await context.push('${RoutePaths.publicCard}/$slug');
  }

  Future<void> _addToContacts() async {
    final slug = visitor.viewerCardSlug?.trim();
    if (slug == null || slug.isEmpty) return;

    setState(() => _isAddingContact = true);
    try {
      await context.read<ContactsProvider>().exchangeFromCardSlug(slug);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.cardVisitorDetailContactAdded(visitor.displayName),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cardVisitorDetailContactError)),
      );
    } finally {
      if (mounted) setState(() => _isAddingContact = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final local = visitor.viewedAt.toLocal();
    final dateLabel = DateFormat.yMMMMd(locale).format(local);
    final timeLabel = DateFormat.Hm(locale).format(local);
    final avatarUrl = ApiConfig.resolvePublicAssetUrl(visitor.avatarUrl);
    String yesNo(bool value) =>
        value ? l10n.cardVisitorDetailYes : l10n.cardVisitorDetailNo;

    return Scaffold(
      backgroundColor: _D.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  const LinkBackButton(),
                  Expanded(
                    child: Text(
                      l10n.cardVisitorDetailTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // ── Profile card ──────────────────────────────────────────
                  _Card(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Avatar(
                              initials: visitor.initials,
                              imageUrl: avatarUrl,
                              isDropOne: _isDropOne,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isDropOne) ...[
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            visitor.displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: context.rs(18),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const _DropOneBadge(),
                                      ],
                                    ),
                                    if (visitor.subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        visitor.subtitle,
                                        style: TextStyle(
                                          color: _D.label,
                                          fontSize: context.rs(13),
                                        ),
                                      ),
                                    ],
                                  ] else ...[
                                    Text(
                                      l10n.cardVisitorDetailAnonymousName,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: context.rs(18),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const _GuestBadge(),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.cardVisitorDetailAnonymousSubtitle,
                                      style: TextStyle(
                                        color: _D.label,
                                        fontSize: context.rs(13),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isDropOne)
                          _PrimaryButton(
                            icon: Icons.visibility_outlined,
                            label: l10n.cardVisitorDetailViewCard,
                            onPressed: visitor.viewerCardSlug == null
                                ? null
                                : _viewCard,
                          )
                        else
                          _OutlineButton(
                            icon: Icons.person_add_alt_1_outlined,
                            label: l10n.cardVisitorDetailInviteCta,
                            onPressed: _invite,
                          ),
                        if (!_isDropOne) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _D.actionBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: _D.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.cardVisitorDetailAnonymousTip,
                                    style: TextStyle(
                                      color: _D.label,
                                      fontSize: context.rs(12),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Consultation info ─────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cardVisitorDetailConsultationTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.rs(16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: l10n.cardVisitorDetailDate,
                          value: dateLabel,
                        ),
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          label: l10n.cardVisitorDetailTime,
                          value: timeLabel,
                        ),
                        _InfoRow(
                          icon: _sourceIcon,
                          label: l10n.cardVisitorDetailMethod,
                          value: _sourceLabel(context),
                        ),
                        _InfoRow(
                          icon: Icons.timer_outlined,
                          label: l10n.cardVisitorDetailDuration,
                          value: _formatDuration(context),
                        ),
                        if (!_isDropOne) ...[
                          _InfoRow(
                            icon: Icons.my_location_outlined,
                            label: l10n.cardVisitorDetailLocation,
                            value: visitor.locationLabel?.trim().isNotEmpty ==
                                    true
                                ? visitor.locationLabel!
                                : l10n.cardVisitorDetailUnavailable,
                          ),
                          _InfoRow(
                            icon: Icons.phone_iphone_outlined,
                            label: l10n.cardVisitorDetailDevice,
                            value: visitor.deviceLabel?.trim().isNotEmpty == true
                                ? visitor.deviceLabel!
                                : l10n.cardVisitorDetailUnavailable,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: _D.border),
                        ),
                        _InfoRow(
                          icon: Icons.bookmark_border_rounded,
                          label: l10n.cardVisitorDetailSaved,
                          value: yesNo(visitor.hasSaved),
                          valueColor: visitor.hasSaved ? _D.yes : _D.no,
                        ),
                        _InfoRow(
                          icon: Icons.reply_rounded,
                          label: l10n.cardVisitorDetailShared,
                          value: yesNo(visitor.hasShared),
                          valueColor: visitor.hasShared ? _D.yes : _D.no,
                        ),
                      ],
                    ),
                  ),

                  // ── Invite banner (anonymous only) ────────────────────────
                  if (!_isDropOne) ...[
                    const SizedBox(height: 12),
                    _InviteBanner(onInvite: _invite),
                  ],

                  // ── Actions ───────────────────────────────────────────────
                  const SizedBox(height: 20),
                  Text(
                    l10n.cardVisitorDetailActionsTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.send_outlined,
                    title: l10n.cardVisitorDetailSendMessage,
                    onTap: _sendMessage,
                  ),
                  if (_isDropOne) ...[
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.person_add_alt_1_outlined,
                      title: l10n.cardVisitorDetailAddContact,
                      onTap: _isAddingContact || visitor.viewerCardSlug == null
                          ? null
                          : _addToContacts,
                      isLoading: _isAddingContact,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _ActionTile(
                    icon: Icons.ios_share_outlined,
                    title: l10n.cardVisitorDetailShareProfile,
                    onTap: _shareProfile,
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _D.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _D.border),
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.isDropOne,
    this.imageUrl,
  });

  final String initials;
  final bool isDropOne;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (!isDropOne) {
      return Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: _D.actionBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 28, color: _D.meta),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: _D.blue,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _D.dropOneBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              color: _D.dropOneFg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 9, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.cardVisitorsFilterDropOne,
            style: TextStyle(
              color: _D.dropOneFg,
              fontSize: context.rs(11),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestBadge extends StatelessWidget {
  const _GuestBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _D.guestBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.cardVisitorDetailGuestBadge,
        style: TextStyle(
          color: _D.guestFg,
          fontSize: context.rs(11),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _D.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _D.blue.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rs(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _D.blue,
          side: const BorderSide(color: _D.blue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rs(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22),
          ],
        ),
      ),
    );
  }
}

class _InviteBanner extends StatelessWidget {
  const _InviteBanner({required this.onInvite});

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.blueSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _D.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cardVisitorDetailInviteBannerTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.cardVisitorDetailInviteBannerBody,
                  style: TextStyle(
                    color: _D.label,
                    fontSize: context.rs(11),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onInvite,
            style: OutlinedButton.styleFrom(
              foregroundColor: _D.blue,
              backgroundColor: Colors.white,
              side: const BorderSide(color: _D.blue),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.cardVisitorDetailInviteShort,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _D.meta),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _D.label,
                fontSize: context.rs(13),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: context.rs(13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _D.actionBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, color: _D.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _D.meta, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
