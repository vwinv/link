import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:linkflutter/features/scan/models/scan_contact_draft.dart';

class BusinessCardOcrException implements Exception {
  BusinessCardOcrException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BusinessCardOcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<void> dispose() => _textRecognizer.close();

  Future<ScanContactDraft> extractFromImagePath(String imagePath) async {
    final recognizedText = await _textRecognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );

    final rawText = recognizedText.text.trim();
    if (rawText.isEmpty) {
      throw BusinessCardOcrException('empty');
    }

    final draft = _parseRecognizedText(rawText);
    if (!draft.hasMeaningfulData) {
      throw BusinessCardOcrException('unreadable');
    }

    return draft;
  }

  ScanContactDraft _parseRecognizedText(String rawText) {
    final lines = rawText
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final emailRegex = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    );
    final phoneRegex = RegExp(
      r'(?:\+|00)?[\d][\d\s().-]{7,}[\d]',
    );

    final droponeSlugRegex = RegExp(
      r'(?:https?://)?(?:www\.)?dropone\.pro/cards/([a-z0-9-]+)',
      caseSensitive: false,
    );
    // Lignes de type site web / réseau social (hors e-mail) : à ignorer.
    final urlRegex = RegExp(
      r'(https?://|www\.)|\.(com|fr|pro|net|org|io|co|sn|dev|app)(/|$)',
      caseSensitive: false,
    );

    String? detectedDroponeSlug;
    String? email;
    String? phone;
    final contentLines = <String>[];

    for (final line in lines) {
      final droponeMatch = droponeSlugRegex.firstMatch(line);
      if (droponeMatch != null) {
        detectedDroponeSlug ??= droponeMatch.group(1)?.trim().toLowerCase();
        continue;
      }

      final emailMatch = emailRegex.firstMatch(line);
      if (emailMatch != null) {
        email ??= emailMatch.group(0);
        final remainder = line.replaceFirst(emailMatch.group(0)!, '').trim();
        if (remainder.isNotEmpty && !urlRegex.hasMatch(remainder)) {
          contentLines.add(remainder);
        }
        continue;
      }

      if (phone == null && _looksLikePhone(line, phoneRegex)) {
        phone = _normalizePhone(line);
        continue;
      }

      // On écarte les URL/sites web : ils ne doivent jamais atterrir dans
      // le poste ou l'entreprise.
      if (urlRegex.hasMatch(line)) {
        continue;
      }

      contentLines.add(line);
    }

    // Détection ciblée : on ne remplit un champ que s'il est réellement
    // identifié, sinon on le laisse vide.
    String? jobTitle;
    String? company;
    final usedIndexes = <int>{};

    for (var i = 0; i < contentLines.length; i++) {
      final line = contentLines[i];
      if (jobTitle == null && _looksLikeJobTitle(line)) {
        jobTitle = line;
        usedIndexes.add(i);
        continue;
      }
      if (company == null && _looksLikeCompany(line)) {
        company = line;
        usedIndexes.add(i);
      }
    }

    // Le nom : première ligne restante qui ressemble à un nom de personne.
    var firstName = '';
    var lastName = '';
    for (var i = 0; i < contentLines.length; i++) {
      if (usedIndexes.contains(i)) continue;
      if (!_looksLikeName(contentLines[i])) continue;
      final name = _splitName(contentLines[i]);
      firstName = name.$1;
      lastName = name.$2;
      break;
    }

    return ScanContactDraft(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      jobTitle: jobTitle,
      company: company,
      rawText: rawText,
      detectedDroponeSlug: detectedDroponeSlug,
    );
  }

  static final _jobTitleKeywords = <String>[
    'ceo', 'cto', 'coo', 'cfo', 'cmo', 'founder', 'co-founder', 'fondateur',
    'fondatrice', 'president', 'président', 'directeur', 'directrice',
    'director', 'manager', 'responsable', 'chef', 'head of', 'lead',
    'developer', 'développeur', 'developpeur', 'engineer', 'ingénieur',
    'ingenieur', 'consultant', 'designer', 'architect', 'architecte',
    'analyst', 'analyste', 'marketing', 'sales', 'commercial', 'commerciale',
    'account', 'officer', 'assistant', 'assistante', 'gérant', 'gerant',
    'owner', 'partner', 'associé', 'associe', 'specialist', 'spécialiste',
    'coordinateur', 'coordinatrice', 'technicien', 'technicienne', 'avocat',
    'comptable', 'product', 'project', 'chargé', 'chargée', 'freelance',
  ];

  static final _companyKeywords = <String>[
    'inc', 'inc.', 'llc', 'ltd', 'ltd.', 'limited', 'corp', 'corp.',
    'corporation', 'company', 'co.', 'sarl', 'sas', 'sasu', 'sa', 'eurl',
    'gmbh', 'ag', 'group', 'groupe', 'studio', 'studios', 'agency', 'agence',
    'technologies', 'technology', 'solutions', 'consulting', 'services',
    'labs', 'lab', 'ventures', 'partners', 'holding', 'industries',
    'entreprise', 'société', 'societe', 'sn', 'international',
  ];

  bool _looksLikeJobTitle(String line) {
    final lower = line.toLowerCase();
    return _jobTitleKeywords.any(
      (keyword) => RegExp('\\b${RegExp.escape(keyword)}\\b').hasMatch(lower),
    );
  }

  bool _looksLikeCompany(String line) {
    final lower = line.toLowerCase();
    return _companyKeywords.any(
      (keyword) => RegExp('\\b${RegExp.escape(keyword)}\\b').hasMatch(lower),
    );
  }

  bool _looksLikeName(String line) {
    final cleaned = line
        .replaceAll(RegExp(r"[^A-Za-zÀ-ÖØ-öø-ÿ\s'-]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return false;

    final tokens = cleaned.split(' ');
    if (tokens.length > 4) return false;
    // Au moins un mot alphabétique de 2 caractères ou plus.
    return tokens.any((token) => token.length >= 2);
  }

  bool _looksLikePhone(String line, RegExp phoneRegex) {
    final digits = line.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return false;
    return phoneRegex.hasMatch(line);
  }

  String _normalizePhone(String line) {
    return line.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }

  (String, String) _splitName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r"[^A-Za-zÀ-ÖØ-öø-ÿ\s'-]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return ('', '');
    }

    final parts = cleaned.split(' ');
    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }
}
