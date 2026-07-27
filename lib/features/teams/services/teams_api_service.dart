import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/models/team_invitation.dart';
import 'package:linkflutter/features/teams/models/team_member.dart';
import 'package:linkflutter/features/teams/models/team_seats_quota.dart';

class TeamsApiService {
  TeamsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Team> createTeam({
    required String name,
    String? description,
    String? logoUrl,
    String? brandColor,
  }) async {
    final response = await _apiClient.post(
      '/teams',
      authenticated: true,
      body: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
        if (brandColor != null && brandColor.isNotEmpty) 'brandColor': brandColor,
      },
    );
    return Team.fromJson(response);
  }

  Future<List<Team>> fetchMyTeams() async {
    final response = await _apiClient.getList(
      '/teams',
      authenticated: true,
    );

    final teams = <Team>[];
    for (final item in response) {
      if (item is! Map) continue;
      try {
        teams.add(Team.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        // Ignore malformed team payloads.
      }
    }
    return teams;
  }

  Future<Team> fetchTeam(String teamId) async {
    final response = await _apiClient.get(
      '/teams/$teamId',
      authenticated: true,
    );
    return Team.fromJson(response);
  }

  Future<({List<TeamMember> members, TeamSeatsQuota seats})> fetchTeamMembers(
    String teamId,
  ) async {
    final response = await _apiClient.get(
      '/teams/$teamId/members',
      authenticated: true,
    );

    final map = Map<String, dynamic>.from(response);
    final membersJson = map['members'];
    final pendingInvitesJson = map['pendingInvites'];
    final seatsJson = map['seats'];

    final members = <TeamMember>[];
    if (membersJson is List) {
      for (final item in membersJson) {
        if (item is! Map) continue;
        try {
          members.add(TeamMember.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Ignore malformed member payloads.
        }
      }
    }

    if (pendingInvitesJson is List) {
      for (final item in pendingInvitesJson) {
        if (item is! Map) continue;
        try {
          members.add(
            TeamMember.fromPendingInvite(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          // Ignore malformed invite payloads.
        }
      }
    }

    final seats = seatsJson is Map
        ? TeamSeatsQuota.fromJson(Map<String, dynamic>.from(seatsJson))
        : TeamSeatsQuota.empty;

    return (members: members, seats: seats);
  }

  Future<void> addTeamMember({
    required String teamId,
    required String email,
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? avatarUrl,
    TeamMemberRole role = TeamMemberRole.member,
  }) async {
    await _apiClient.post(
      '/teams/$teamId/members',
      authenticated: true,
      body: {
        'email': email.trim().toLowerCase(),
        if (firstName != null && firstName.isNotEmpty) 'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        if (jobTitle != null && jobTitle.isNotEmpty) 'jobTitle': jobTitle,
        if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        'role': role.name.toUpperCase(),
      },
    );
  }

  Future<List<TeamInvitation>> fetchMyInvitations() async {
    final response = await _apiClient.getList(
      '/teams/invitations/me',
      authenticated: true,
    );

    final invitations = <TeamInvitation>[];
    for (final item in response) {
      if (item is! Map) continue;
      try {
        invitations.add(
          TeamInvitation.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Ignore malformed invitation payloads.
      }
    }
    return invitations;
  }

  Future<void> acceptTeamInvitation(String inviteId) async {
    await _apiClient.post(
      '/teams/invitations/$inviteId/accept',
      authenticated: true,
    );
  }

  Future<void> declineTeamInvitation(String inviteId) async {
    await _apiClient.post(
      '/teams/invitations/$inviteId/decline',
      authenticated: true,
    );
  }

  Future<void> cancelTeamInvitation({
    required String teamId,
    required String inviteId,
  }) async {
    await _apiClient.delete(
      '/teams/$teamId/invitations/$inviteId',
      authenticated: true,
    );
  }

  Future<void> removeTeamMember({
    required String teamId,
    required String memberId,
  }) async {
    await _apiClient.delete(
      '/teams/$teamId/members/$memberId',
      authenticated: true,
    );
  }
}
