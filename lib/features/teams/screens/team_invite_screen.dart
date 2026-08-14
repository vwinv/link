import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/teams/models/team_invitation.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:provider/provider.dart';

/// Résultat de l’écran d’invitation - non utilisé hors navigation.
class TeamInviteScreen extends StatefulWidget {
  const TeamInviteScreen({super.key, required this.invitation});

  final TeamInvitation invitation;

  @override
  State<TeamInviteScreen> createState() => _TeamInviteScreenState();
}

class _TeamInviteScreenState extends State<TeamInviteScreen> {
  var _isProcessing = false;

  Future<void> _closeAndGoHome() async {
    if (!mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    if (!mounted) return;
    context.go(RoutePaths.home);
  }

  Future<void> _respond({required bool accept}) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final teamsApi = context.read<TeamsApiService>();
    final teams = context.read<TeamsProvider>();
    final workspace = context.read<WorkspaceModeProvider>();
    final user = context.read<AuthProvider>().user;

    try {
      if (accept) {
        await teamsApi.acceptTeamInvitation(widget.invitation.id);
        if (user != null) {
          teams.setCurrentUserId(user.id);
        }
        await teams.load(force: true);
        await context.read<CardsProvider>().load(force: true);
        await workspace.switchToMember();
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.teamInvitationAccepted(widget.invitation.teamName),
            ),
          ),
        );
        await _closeAndGoHome();
      } else {
        await teamsApi.declineTeamInvitation(widget.invitation.id);
        await workspace.switchToPersonal();
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.teamInvitationDeclinedBlocked)),
        );
        await _closeAndGoHome();
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamInvitationRespondError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final invitation = widget.invitation;
    final logoUrl = ApiConfig.resolvePublicAssetUrl(invitation.teamLogoUrl);
    final brand =
        invitation.toTeam().brandColorValue ?? AppColors.bleu_primaire;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _isProcessing
              ? null
              : () async {
                  // « Plus tard » : invite reste en attente.
                  await context
                      .read<WorkspaceModeProvider>()
                      .switchToPersonal();
                  await _closeAndGoHome();
                },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                clipBehavior: Clip.antiAlias,
                child: logoUrl != null
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _TeamInitials(
                          initials: invitation.toTeam().initials,
                          color: brand,
                        ),
                      )
                    : _TeamInitials(
                        initials: invitation.toTeam().initials,
                        color: brand,
                      ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.teamInviteScreenTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.rs(22),
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                invitation.invitedByName != null
                    ? l10n.teamInvitationMessageWithInviter(
                        invitation.invitedByName!,
                        invitation.teamName,
                      )
                    : l10n.teamInvitationMessage(invitation.teamName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.rs(15),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_rounded, color: brand, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        invitation.teamName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.rs(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isProcessing ? null : () => _respond(accept: true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.bleu_primaire,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.teamInvitationAccept,
                          style: TextStyle(
                            fontSize: context.rs(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed:
                      _isProcessing ? null : () => _respond(accept: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: Color(0xFFE5E5EA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.teamInvitationDecline,
                    style: TextStyle(
                      fontSize: context.rs(16),
                      fontWeight: FontWeight.w600,
                    ),
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

class _TeamInitials extends StatelessWidget {
  const _TeamInitials({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
