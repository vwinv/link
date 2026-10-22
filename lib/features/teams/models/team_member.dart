import 'package:flutter/material.dart';

enum TeamMemberRole {
  owner,
  admin,
  member;

  static TeamMemberRole fromKey(String? value) {
    switch (value?.toUpperCase()) {
      case 'OWNER':
        return TeamMemberRole.owner;
      case 'ADMIN':
        return TeamMemberRole.admin;
      default:
        return TeamMemberRole.member;
    }
  }

  String get label {
    switch (this) {
      case TeamMemberRole.owner:
      case TeamMemberRole.admin:
        return 'Admin';
      case TeamMemberRole.member:
        return 'Membre';
    }
  }

  bool get isAdmin =>
      this == TeamMemberRole.owner || this == TeamMemberRole.admin;
}

enum TeamMemberStatus {
  active,
  pending;

  String get label {
    switch (this) {
      case TeamMemberStatus.active:
        return 'Actif';
      case TeamMemberStatus.pending:
        return 'En attente';
    }
  }
}

class TeamMember {
  const TeamMember({
    required this.id,
    required this.userId,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.email,
    this.avatarUrl,
    this.jobTitle,
    this.status = TeamMemberStatus.active,
    this.isPendingInvite = false,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map
        ? Map<String, dynamic>.from(user)
        : <String, dynamic>{};

    return TeamMember(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? userMap['id'] as String? ?? '',
      role: TeamMemberRole.fromKey(json['role'] as String?),
      firstName: userMap['firstName'] as String? ?? '',
      lastName: userMap['lastName'] as String? ?? '',
      email: userMap['email'] as String? ?? json['email'] as String?,
      avatarUrl: userMap['avatarUrl'] as String?,
      jobTitle: userMap['jobTitle'] as String? ?? json['jobTitle'] as String?,
      status: TeamMemberStatus.active,
    );
  }

  factory TeamMember.fromPendingInvite(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';

    return TeamMember(
      id: json['id'] as String,
      userId: '',
      role: TeamMemberRole.fromKey(json['role'] as String?),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: email,
      avatarUrl: json['avatarUrl'] as String?,
      jobTitle: json['jobTitle'] as String?,
      status: TeamMemberStatus.pending,
      isPendingInvite: true,
    );
  }

  final String id;
  final String userId;
  final TeamMemberRole role;
  final String firstName;
  final String lastName;
  final String? email;
  final String? avatarUrl;
  final String? jobTitle;
  final TeamMemberStatus status;
  final bool isPendingInvite;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? (email ?? 'Membre') : name;
  }

  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.length >= 2
          ? first.substring(0, 2).toUpperCase()
          : first[0].toUpperCase();
    }
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) {
      return mail.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String get subtitle {
    final title = jobTitle?.trim();
    final roleLabel = role.label;
    if (title != null && title.isNotEmpty) {
      return '$title - $roleLabel';
    }
    return roleLabel;
  }

  Color avatarColorForIndex(int index) {
    const colors = [
      Color(0xFF64B5F6),
      Color(0xFFF48FB1),
      Color(0xFF81C784),
      Color(0xFFFFB74D),
      Color(0xFFBA68C8),
      Color(0xFF4DB6AC),
    ];
    return colors[index % colors.length];
  }
}
