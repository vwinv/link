class TeamSeatsQuota {
  const TeamSeatsQuota({
    required this.used,
    required this.max,
    required this.canAddMember,
  });

  factory TeamSeatsQuota.fromJson(Map<String, dynamic> json) {
    return TeamSeatsQuota(
      used: json['used'] as int? ?? 0,
      max: json['max'] as int? ?? 0,
      canAddMember: json['canAddMember'] as bool? ?? false,
    );
  }

  static const empty = TeamSeatsQuota(used: 0, max: 0, canAddMember: false);

  final int used;
  final int max;
  final bool canAddMember;
}
