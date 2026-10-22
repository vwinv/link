import 'package:flutter/material.dart';

enum ContactSource {
  exchange,
  aiScan;

  static ContactSource fromKey(String? key) {
    switch (key) {
      case 'AI_SCAN':
        return ContactSource.aiScan;
      case 'EXCHANGE':
      default:
        return ContactSource.exchange;
    }
  }

  String get label {
    switch (this) {
      case ContactSource.exchange:
        return 'Échange DropOne';
      case ContactSource.aiScan:
        return 'Scan IA';
    }
  }
}

class LinkContact {
  const LinkContact({
    required this.id,
    required this.source,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    required this.addedAgo,
    required this.avatarColor,
    this.createdAt,
    this.email,
    this.phone,
    this.jobTitle,
    this.company,
    this.linkedCardId,
    this.linkedCardSlug,
    this.avatarUrl,
  });

  factory LinkContact.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'] as String?;
    return LinkContact(
      id: json['id'] as String,
      source: ContactSource.fromKey(json['source'] as String?),
      fullName: json['fullName'] as String,
      initials: json['initials'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      addedAgo: json['addedAgo'] as String? ??
          json['sharedAgo'] as String? ??
          '',
      avatarColor: _parseAvatarColor(json['avatarColor'] as int?),
      createdAt:
          createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      company: json['company'] as String?,
      linkedCardId: json['linkedCardId'] as String?,
      linkedCardSlug: json['linkedCardSlug'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String id;
  final ContactSource source;
  final String fullName;
  final String initials;
  final String subtitle;
  final String addedAgo;
  final Color avatarColor;
  final DateTime? createdAt;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final String? company;
  final String? linkedCardId;
  final String? linkedCardSlug;
  final String? avatarUrl;

  bool get isDropOneContact =>
      source == ContactSource.exchange &&
      (linkedCardSlug?.trim().isNotEmpty ?? false);

  String get shortAddedAgo => formatShortTimeAgo(createdAt);
}

Color _parseAvatarColor(int? value) {
  final color = value ?? 0x0a6bff;
  if (color > 0xffffff) return Color(color);
  return Color(0xff000000 | color);
}

String formatShortTimeAgo(DateTime? date) {
  if (date == null) return '';

  final diff = DateTime.now().difference(date.toLocal());
  final minutes = diff.inMinutes;
  if (minutes < 1) return 'À l’instant';
  if (minutes < 60) return '$minutes min';

  final hours = diff.inHours;
  if (hours < 24) return '${hours}h';

  final days = diff.inDays;
  if (days == 1) return 'Hier';
  if (days < 7) return '$days j';

  final weeks = (days / 7).floor();
  if (weeks < 5) return '$weeks sem.';

  final months = (days / 30).floor();
  if (months < 12) return '$months mois';

  final years = (days / 365).floor();
  return '$years an${years > 1 ? 's' : ''}';
}

String formatContactsCount(int count) {
  if (count == 0) return 'Aucun contact enregistré';
  if (count == 1) return '1 contact enregistré';
  return '$count contacts enregistrés';
}
