import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/app_update/models/app_version_info.dart';
import 'package:linkflutter/features/app_update/services/app_update_service.dart';
import 'package:provider/provider.dart';

/// Bottom sheet persistante (hors routes) pour la mise à jour app.
class AppUpdateBottomSheetOverlay extends StatelessWidget {
  const AppUpdateBottomSheetOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final requirement = context.watch<AppUpdateService>().pending;
    if (requirement == null) return const SizedBox.shrink();

    final forced = requirement.kind == AppUpdateKind.force;

    return Positioned.fill(
      child: Stack(
        children: [
          if (forced)
            const ModalBarrier(
              dismissible: false,
              color: Color(0x660C0D10),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _AppUpdateSheetCard(requirement: requirement),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppUpdateSheetCard extends StatefulWidget {
  const _AppUpdateSheetCard({required this.requirement});

  final AppUpdateRequirement requirement;

  @override
  State<_AppUpdateSheetCard> createState() => _AppUpdateSheetCardState();
}

class _AppUpdateSheetCardState extends State<_AppUpdateSheetCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    final forced = widget.requirement.kind == AppUpdateKind.force;
    if (forced) return;
    await _controller.reverse();
    if (!mounted) return;
    await context.read<AppUpdateService>().dismissSoft();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final forced = widget.requirement.kind == AppUpdateKind.force;
    final title =
        forced ? l10n.appUpdateForceTitle : l10n.appUpdateSoftTitle;
    final message = widget.requirement.message.isNotEmpty
        ? widget.requirement.message
        : (forced ? l10n.appUpdateForceMessage : l10n.appUpdateSoftMessage);

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x290C0D10),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.dotInactive,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          AppAssets.icone,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!forced)
                        IconButton(
                          onPressed: _dismiss,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (!forced) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _dismiss,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(l10n.appUpdateLater),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              context.read<AppUpdateService>().openStore(),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: AppColors.bleu_primaire,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.appUpdateCta),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
