import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/teams/models/team_invitation.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

Future<void> promptPendingTeamInvitations(BuildContext context) async {
  final teamsApi = context.read<TeamsApiService>();
  List<TeamInvitation> invitations;

  try {
    invitations = await teamsApi.fetchMyInvitations();
  } catch (_) {
    return;
  }

  if (!context.mounted || invitations.isEmpty) return;

  for (final invitation in invitations) {
    if (!context.mounted) return;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _TeamInvitationDialog(invitation: invitation),
    );

    if (accepted == true && context.mounted) {
      await context.read<TeamsProvider>().load();
    }
  }
}

class _TeamInvitationDialog extends StatefulWidget {
  const _TeamInvitationDialog({required this.invitation});

  final TeamInvitation invitation;

  @override
  State<_TeamInvitationDialog> createState() => _TeamInvitationDialogState();
}

class _TeamInvitationDialogState extends State<_TeamInvitationDialog> {
  var _isProcessing = false;

  Future<void> _accept() => _respond(accept: true);

  Future<void> _decline() => _respond(accept: false);

  Future<void> _respond({required bool accept}) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    try {
      final teamsApi = context.read<TeamsApiService>();
      if (accept) {
        await teamsApi.acceptTeamInvitation(widget.invitation.id);
      } else {
        await teamsApi.declineTeamInvitation(widget.invitation.id);
      }
      if (!mounted) return;
      Navigator.of(context).pop(accept);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? l10n.teamInvitationAccepted(widget.invitation.teamName)
                : l10n.teamInvitationDeclined,
          ),
        ),
      );
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
    final invitedBy = invitation.invitedByName;

    return AlertDialog(
      title: Text(l10n.teamInvitationTitle),
      content: Text(
        invitedBy != null
            ? l10n.teamInvitationMessageWithInviter(
                invitedBy,
                invitation.teamName,
              )
            : l10n.teamInvitationMessage(invitation.teamName),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : _decline,
          child: Text(l10n.teamInvitationDecline),
        ),
        FilledButton(
          onPressed: _isProcessing ? null : _accept,
          child: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.teamInvitationAccept),
        ),
      ],
    );
  }
}
