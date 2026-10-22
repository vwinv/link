import 'package:flutter/foundation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/auth/models/user.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_draft.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';
import 'package:linkflutter/features/cards/models/social_link_draft.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';

class CreateCardProvider extends ChangeNotifier {
  CreateCardProvider({required CardsApiService cardsApi}) : _cardsApi = cardsApi;

  final CardsApiService _cardsApi;

  CardDraft _draft = const CardDraft();
  BusinessCard? _card;
  List<SocialLinkDraft> _socialLinks = SocialLinkDraft.initialDefaults();
  int _currentStep = 1;
  bool _isSaving = false;
  bool _fromExistingWorkspace = false;
  String? _errorMessage;

  CardDraft get draft => _draft;
  BusinessCard? get card => _card;
  List<SocialLinkDraft> get socialLinks => _socialLinks;
  String? get cardId => _card?.id;
  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;
  bool get fromExistingWorkspace => _fromExistingWorkspace;
  String? get errorMessage => _errorMessage;

  void initFromUser(
    User? user, {
    bool fromExistingWorkspace = false,
  }) {
    if (user == null) return;

    _draft = CardDraft(
      fullName: user.fullName,
      email: user.email,
      phone: user.phone ?? '',
    );
    _card = null;
    _socialLinks = SocialLinkDraft.initialDefaults();
    _currentStep = 1;
    _fromExistingWorkspace = fromExistingWorkspace;
    _errorMessage = null;
    notifyListeners();
  }

  void initSocialLinks() {
    _socialLinks = SocialLinkDraft.initialDefaults();
    notifyListeners();
  }

  void toggleSocialLink(CardSocialPlatform platform, bool isSelected) {
    _socialLinks = _socialLinks
        .map(
          (link) => link.platform == platform
              ? link.copyWith(isSelected: isSelected)
              : link,
        )
        .toList();
    notifyListeners();
  }

  void updateSocialLinkValue(CardSocialPlatform platform, String value) {
    _socialLinks = _socialLinks
        .map(
          (link) =>
              link.platform == platform ? link.copyWith(value: value) : link,
        )
        .toList();
  }

  void updateStep1({
    required String fullName,
    required String jobTitle,
    required String company,
    required String email,
    required String phone,
  }) {
    _draft = _draft.copyWith(
      fullName: fullName,
      jobTitle: jobTitle,
      company: company,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }

  Future<bool> saveStep1() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final name = _draft.splitName;
      final jobTitle = _draft.jobTitle.trim();
      final company = _draft.company.trim();
      final email = _draft.email.trim();
      final phone = _draft.phone.trim();

      if (_card != null) {
        _card = await _cardsApi.updateCard(
          _card!.id,
          firstName: name.firstName,
          lastName: name.lastName,
          jobTitle: jobTitle.isEmpty ? null : jobTitle,
          company: company.isEmpty ? null : company,
          email: email.isEmpty ? null : email,
          phone: phone.isEmpty ? null : phone,
        );
      } else {
        _card = await _cardsApi.createCard(
          firstName: name.firstName,
          lastName: name.lastName,
          jobTitle: jobTitle.isEmpty ? null : jobTitle,
          company: company.isEmpty ? null : company,
          email: email.isEmpty ? null : email,
          phone: phone.isEmpty ? null : phone,
        );
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible d\'enregistrer la carte';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveStep2() async {
    if (_card == null) {
      _errorMessage = 'Carte introuvable. Recommencez depuis l’étape 1.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final links = _socialLinks
          .where((link) => link.isSelected && link.value.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => {
              'platform': entry.value.platform.apiValue,
              'url': entry.value.platform.shareUrl(entry.value.value),
              'order': entry.key,
            },
          )
          .toList();

      await _cardsApi.syncSocialLinks(_card!.id, links);

      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible d\'enregistrer les réseaux';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void reset() {
    _draft = const CardDraft();
    _card = null;
    _socialLinks = SocialLinkDraft.initialDefaults();
    _currentStep = 1;
    _fromExistingWorkspace = false;
    _errorMessage = null;
    notifyListeners();
  }
}
