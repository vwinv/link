class CardDraft {
  const CardDraft({
    this.fullName = '',
    this.jobTitle = '',
    this.company = '',
    this.email = '',
    this.phone = '',
  });

  final String fullName;
  final String jobTitle;
  final String company;
  final String email;
  final String phone;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'XX';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get subtitle {
    final job = jobTitle.trim();
    final org = company.trim();
    if (job.isEmpty && org.isEmpty) return '';
    if (job.isEmpty) return org;
    if (org.isEmpty) return job;
    return '$job - $org';
  }

  ({String firstName, String lastName}) get splitName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return (firstName: '', lastName: '');
    }
    if (parts.length == 1) {
      return (firstName: parts.first, lastName: parts.first);
    }
    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }

  CardDraft copyWith({
    String? fullName,
    String? jobTitle,
    String? company,
    String? email,
    String? phone,
  }) {
    return CardDraft(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
