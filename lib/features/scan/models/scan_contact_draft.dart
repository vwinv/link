class ScanContactDraft {
  const ScanContactDraft({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.jobTitle,
    this.company,
    this.rawText = '',
    this.detectedDroponeSlug,
  });

  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final String? company;
  final String rawText;
  final String? detectedDroponeSlug;

  String get fullName => '$firstName $lastName'.trim();

  bool get hasMeaningfulData {
    if (email?.trim().isNotEmpty == true) return true;
    if (phone?.trim().isNotEmpty == true) return true;
    if (jobTitle?.trim().isNotEmpty == true) return true;
    if (company?.trim().isNotEmpty == true) return true;
    return fullName.trim().isNotEmpty;
  }

  Map<String, dynamic> toApiBody() {
    final body = <String, dynamic>{};

    final firstNameValue = firstName.trim();
    if (firstNameValue.isNotEmpty) {
      body['firstName'] = firstNameValue;
    }

    final lastNameValue = lastName.trim();
    if (lastNameValue.isNotEmpty) {
      body['lastName'] = lastNameValue;
    }

    final emailValue = email?.trim();
    if (emailValue != null && emailValue.isNotEmpty) {
      body['email'] = emailValue;
    }

    final phoneValue = phone?.trim();
    if (phoneValue != null && phoneValue.isNotEmpty) {
      body['phone'] = phoneValue;
    }

    final jobValue = jobTitle?.trim();
    if (jobValue != null && jobValue.isNotEmpty) {
      body['jobTitle'] = jobValue;
    }

    final companyValue = company?.trim();
    if (companyValue != null && companyValue.isNotEmpty) {
      body['company'] = companyValue;
    }

    final slugValue = detectedDroponeSlug?.trim().toLowerCase();
    if (slugValue != null && slugValue.isNotEmpty) {
      body['cardSlug'] = slugValue;
    }

    return body;
  }

  ScanContactDraft copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? jobTitle,
    String? company,
    String? detectedDroponeSlug,
  }) {
    return ScanContactDraft(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      rawText: rawText,
      detectedDroponeSlug: detectedDroponeSlug ?? this.detectedDroponeSlug,
    );
  }
}
