enum CardKind {
  personal,
  professional,
  member;

  static CardKind fromKey(dynamic key) {
    final normalized = key?.toString().trim().toLowerCase();
    if (normalized == 'professional' || normalized == 'pro') {
      return CardKind.professional;
    }
    if (normalized == 'member') {
      return CardKind.member;
    }
    return CardKind.personal;
  }

  String get apiValue => name.toUpperCase();

  String get tagLabel {
    switch (this) {
      case CardKind.personal:
        return 'Carte perso';
      case CardKind.professional:
        return 'Carte équipe';
      case CardKind.member:
        return 'Carte membre';
    }
  }

  bool get isPersonal => this == CardKind.personal;
  bool get isProfessional => this == CardKind.professional;
  bool get isMember => this == CardKind.member;

  /// Carte liée à une équipe (pro owner ou membre).
  bool get isTeamLinked => isProfessional || isMember;
}
