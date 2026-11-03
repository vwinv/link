import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/teams/models/team_member.dart';

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.brandColor,
    this.ownerId,
    this.myRole = TeamMemberRole.member,
    this.entitlements,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final entitlementsJson = json['entitlements'];
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      brandColor: json['brandColor'] as String?,
      ownerId: json['ownerId'] as String?,
      myRole: TeamMemberRole.fromKey(json['myRole'] as String?),
      entitlements: entitlementsJson is Map
          ? OfferEntitlements.fromJson(
              Map<String, dynamic>.from(entitlementsJson),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'logoUrl': logoUrl,
        'brandColor': brandColor,
        'ownerId': ownerId,
        'myRole': myRole.name.toUpperCase(),
        if (entitlements != null) 'entitlements': entitlements!.toJson(),
      };

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? brandColor;
  final String? ownerId;
  final TeamMemberRole myRole;
  final OfferEntitlements? entitlements;

  bool isOwnedBy(String? userId) =>
      userId != null && ownerId != null && ownerId == userId;

  /// Propriétaire ou admin : adresse / réseaux / marque partagés.
  bool get canManageSharedFields => myRole.isAdmin;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'EQ';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color? get brandColorValue {
    final value = brandColor?.trim();
    if (value == null || value.isEmpty) return null;
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6) return null;
    return Color(int.parse('FF$hex', radix: 16));
  }

  String? get logoImageUrl => ApiConfig.resolvePublicAssetUrl(logoUrl);

  Team copyWith({
    OfferEntitlements? entitlements,
    TeamMemberRole? myRole,
  }) {
    return Team(
      id: id,
      name: name,
      slug: slug,
      description: description,
      logoUrl: logoUrl,
      brandColor: brandColor,
      ownerId: ownerId,
      myRole: myRole ?? this.myRole,
      entitlements: entitlements ?? this.entitlements,
    );
  }
}
