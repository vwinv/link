import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_theme_settings.dart';
import 'package:linkflutter/features/teams/models/team.dart';

class BusinessCard {
  const BusinessCard({
    required this.id,
    required this.slug,
    required this.firstName,
    required this.lastName,
    this.kind = CardKind.personal,
    this.teamId,
    this.jobTitle,
    this.company,
    this.email,
    this.phone,
    this.address,
    this.website,
    this.avatarUrl,
    this.logoUrl,
    this.theme = const CardThemeSettings(),
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    final themeJson = json['theme'];
    return BusinessCard(
      id: json['id'] as String,
      slug: json['slug'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      kind: CardKind.fromKey(json['kind']),
      teamId: json['teamId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      company: json['company'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      theme: CardThemeSettings.fromJson(
        themeJson is Map ? Map<String, dynamic>.from(themeJson) : null,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'firstName': firstName,
        'lastName': lastName,
        'kind': kind.apiValue,
        'teamId': teamId,
        'jobTitle': jobTitle,
        'company': company,
        'email': email,
        'phone': phone,
        'address': address,
        'website': website,
        'avatarUrl': avatarUrl,
        'logoUrl': logoUrl,
        'theme': theme.toJson(),
      };

  final String id;
  final String slug;
  final String firstName;
  final String lastName;
  final CardKind kind;
  final String? teamId;
  final String? jobTitle;
  final String? company;
  final String? email;
  final String? phone;
  final String? address;
  final String? website;
  final String? avatarUrl;
  final String? logoUrl;
  final CardThemeSettings theme;

  String? get avatarImageUrl => ApiConfig.resolvePublicAssetUrl(avatarUrl);

  String? get logoImageUrl => ApiConfig.resolvePublicAssetUrl(logoUrl);

  String? companyLogoImageUrl(Team? team) {
    if (!kind.isTeamLinked) return null;
    return logoImageUrl ?? team?.logoImageUrl;
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty && last.isEmpty) return 'XX';
    if (last.isEmpty) return first[0].toUpperCase();
    return '${first[0]}${last[0]}'.toUpperCase();
  }

  String? get companyInitials {
    final org = company?.trim() ?? '';
    if (org.isEmpty) return null;
    final parts = org.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get subtitle {
    final job = jobTitle?.trim() ?? '';
    final org = company?.trim() ?? '';
    if (job.isEmpty && org.isEmpty) return '';
    if (job.isEmpty) return org;
    if (org.isEmpty) return job;
    return '$job - $org';
  }

  BusinessCard copyWith({
    CardKind? kind,
    String? teamId,
    CardThemeSettings? theme,
    String? jobTitle,
    String? company,
    String? email,
    String? phone,
    String? address,
    String? website,
    String? avatarUrl,
    String? logoUrl,
  }) {
    return BusinessCard(
      id: id,
      slug: slug,
      firstName: firstName,
      lastName: lastName,
      kind: kind ?? this.kind,
      teamId: teamId ?? this.teamId,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      theme: theme ?? this.theme,
    );
  }

  bool get isPersonal => kind.isPersonal;
  bool get isProfessional => kind.isProfessional;
  bool get isMember => kind.isMember;
}
