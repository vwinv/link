class PortfolioExperienceItem {
  PortfolioExperienceItem({
    required this.id,
    required this.role,
    this.company = '',
    this.period = '',
    this.missions = '',
  });

  final String id;
  String role;
  String company;
  String period;
  String missions;

  String get subtitle {
    final org = company.trim();
    final when = period.trim();
    if (org.isEmpty) return when;
    if (when.isEmpty) return org;
    return '$org · $when';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'company': company,
        'period': period,
        'missions': missions,
      };

  factory PortfolioExperienceItem.fromJson(Map<String, dynamic> json) {
    return PortfolioExperienceItem(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      company: json['company'] as String? ?? '',
      period: json['period'] as String? ?? '',
      missions: json['missions'] as String? ?? '',
    );
  }
}

class PortfolioTeachingItem {
  PortfolioTeachingItem({
    required this.id,
    required this.title,
    this.school = '',
    this.year = '',
    this.audience = '',
  });

  final String id;
  String title;
  String school;
  String year;
  String audience;

  String get subtitle {
    final place = school.trim();
    final when = year.trim();
    if (place.isEmpty) return when;
    if (when.isEmpty) return place;
    return '$place · $when';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'school': school,
        'year': year,
        'audience': audience,
      };

  factory PortfolioTeachingItem.fromJson(Map<String, dynamic> json) {
    return PortfolioTeachingItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      school: json['school'] as String? ?? '',
      year: json['year'] as String? ?? '',
      audience: json['audience'] as String? ?? '',
    );
  }
}

class PortfolioSkillItem {
  PortfolioSkillItem({
    required this.id,
    required this.name,
    required this.level,
  });

  final String id;
  String name;
  int level;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
      };

  factory PortfolioSkillItem.fromJson(Map<String, dynamic> json) {
    final raw = json['level'];
    final level = raw is num ? raw.round() : int.tryParse('$raw') ?? 0;
    return PortfolioSkillItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      level: level.clamp(0, 100),
    );
  }
}

class PortfolioWorkItem {
  PortfolioWorkItem({
    this.id,
    required this.title,
    this.caption = '',
    this.imageUrl,
    this.localPath,
    this.projectUrl = '',
  });

  String? id;
  String title;
  String caption;
  String? imageUrl;
  String? localPath;
  String projectUrl;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'description': caption,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (projectUrl.trim().isNotEmpty) 'projectUrl': projectUrl.trim(),
      };

  factory PortfolioWorkItem.fromJson(Map<String, dynamic> json) {
    return PortfolioWorkItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      caption: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      projectUrl: json['projectUrl'] as String? ?? '',
    );
  }
}

class PortfolioProfile {
  const PortfolioProfile({
    required this.exists,
    this.photoUrl,
    this.firstName = '',
    this.lastName = '',
    this.age,
    this.phone = '',
    this.address = '',
    this.hidePersonalDetails = false,
    this.title = '',
    this.description = '',
    this.experiences = const [],
    this.teachings = const [],
    this.skills = const [],
    this.competences = const [],
    this.strengths = const [],
    this.interests = const [],
    this.projects = const [],
  });

  final bool exists;
  final String? photoUrl;
  final String firstName;
  final String lastName;
  final int? age;
  final String phone;
  final String address;
  final bool hidePersonalDetails;
  final String title;
  final String description;
  final List<PortfolioExperienceItem> experiences;
  final List<PortfolioTeachingItem> teachings;
  final List<PortfolioSkillItem> skills;
  final List<String> competences;
  final List<String> strengths;
  final List<String> interests;
  final List<PortfolioWorkItem> projects;

  factory PortfolioProfile.fromJson(Map<String, dynamic> json) {
    if (json['exists'] != true) return const PortfolioProfile(exists: false);
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) {
      final raw = json[key];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((item) => parse(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<String> chips(String key) {
      final raw = json[key];
      if (raw is! List) return [];
      return raw.map((item) => '$item'.trim()).where((item) => item.isNotEmpty).toList();
    }

    final age = json['age'];
    return PortfolioProfile(
      exists: true,
      photoUrl: json['photoUrl'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      age: age is num ? age.round() : int.tryParse('$age'),
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      hidePersonalDetails: json['hidePersonalDetails'] == true,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      experiences: list('experiences', PortfolioExperienceItem.fromJson),
      teachings: list('teachings', PortfolioTeachingItem.fromJson),
      skills: list('skills', PortfolioSkillItem.fromJson),
      competences: chips('competences'),
      strengths: chips('strengths'),
      interests: chips('interests'),
      projects: list('projects', PortfolioWorkItem.fromJson),
    );
  }
}
