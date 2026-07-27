import 'package:linkflutter/features/teams/models/team.dart';

class TeamInvitation {
  const TeamInvitation({
    required this.id,
    required this.email,
    required this.teamId,
    required this.teamName,
    this.teamLogoUrl,
    this.teamBrandColor,
    this.invitedByName,
    this.createdAt,
  });

  factory TeamInvitation.fromJson(Map<String, dynamic> json) {
    final team = json['team'];
    final teamMap = team is Map
        ? Map<String, dynamic>.from(team)
        : <String, dynamic>{};
    final invitedBy = json['invitedBy'];
    final invitedByMap = invitedBy is Map
        ? Map<String, dynamic>.from(invitedBy)
        : <String, dynamic>{};

    final firstName = invitedByMap['firstName'] as String? ?? '';
    final lastName = invitedByMap['lastName'] as String? ?? '';
    final invitedByName = '$firstName $lastName'.trim();

    return TeamInvitation(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      teamId: teamMap['id'] as String? ?? json['teamId'] as String? ?? '',
      teamName: teamMap['name'] as String? ?? '',
      teamLogoUrl: teamMap['logoUrl'] as String?,
      teamBrandColor: teamMap['brandColor'] as String?,
      invitedByName: invitedByName.isEmpty ? null : invitedByName,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  final String id;
  final String email;
  final String teamId;
  final String teamName;
  final String? teamLogoUrl;
  final String? teamBrandColor;
  final String? invitedByName;
  final DateTime? createdAt;

  Team toTeam() {
    return Team(
      id: teamId,
      name: teamName,
      slug: teamId,
      logoUrl: teamLogoUrl,
      brandColor: teamBrandColor,
    );
  }
}
