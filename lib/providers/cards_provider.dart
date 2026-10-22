import 'package:flutter/foundation.dart';
import 'package:linkflutter/features/auth/models/user.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/teams/models/team.dart';

class CardsProvider extends ChangeNotifier {
  CardsProvider({required CardsApiService cardsApi}) : _cardsApi = cardsApi;

  final CardsApiService _cardsApi;

  List<BusinessCard> _cards = [];
  bool _hasCards = false;
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<BusinessCard> get cards => List.unmodifiable(_cards);
  BusinessCard? get primaryCard {
    final personal = personalCard;
    if (personal != null) return personal;
    return _cards.isNotEmpty ? _cards.first : null;
  }

  BusinessCard? get personalCard => cardForKind(CardKind.personal);
  BusinessCard? get professionalCard => cardForKind(CardKind.professional);

  /// Première carte membre (ou celle liée à [teamId] si fourni).
  BusinessCard? memberCard({String? teamId}) {
    for (final card in _cards) {
      if (card.kind != CardKind.member) continue;
      if (teamId == null || card.teamId == teamId) return card;
    }
    return null;
  }

  bool get hasCards => _hasCards;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get hasPersonalCard => personalCard != null;
  bool get hasProfessionalCard => professionalCard != null;
  bool get hasMemberCard => memberCard() != null;

  BusinessCard? cardForKind(CardKind kind) {
    for (final card in _cards) {
      if (card.kind == kind) return card;
    }
    return null;
  }

  void restoreFromCache(List<BusinessCard> cached) {
    if (cached.isEmpty) return;
    _cards = cached;
    _hasCards = true;
    _hasLoaded = true;
    notifyListeners();
  }

  void reset() {
    _cards = [];
    _hasCards = false;
    _isLoading = false;
    _hasLoaded = false;
    _ongoingLoad = null;
    notifyListeners();
  }

  Future<void>? _ongoingLoad;

  Future<void> load({bool force = false}) async {
    if (!force && _ongoingLoad != null) return _ongoingLoad!;

    _ongoingLoad = _performLoad();
    try {
      await _ongoingLoad;
    } finally {
      _ongoingLoad = null;
    }
  }

  Future<void> _performLoad() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _cardsApi.fetchMyCards();
      _cards = _mergeCards(_cards, fetched);
      _hasCards = _cards.isNotEmpty;
    } catch (_) {
      if (!_hasLoaded) {
        _cards = [];
        _hasCards = false;
      }
    }

    _hasLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  List<BusinessCard> _mergeCards(
    List<BusinessCard> local,
    List<BusinessCard> remote,
  ) {
    if (local.isEmpty) return remote;

    final byId = <String, BusinessCard>{
      for (final card in local) card.id: card,
    };
    for (final card in remote) {
      byId[card.id] = card;
    }

    final ordered = <BusinessCard>[];
    final seen = <String>{};
    for (final card in remote) {
      final merged = byId[card.id];
      if (merged == null || !seen.add(card.id)) continue;
      ordered.add(merged);
    }
    for (final card in local) {
      if (seen.add(card.id)) ordered.add(card);
    }
    return ordered;
  }

  void markCardCreated() {
    _hasCards = true;
    notifyListeners();
  }

  void replaceCard(BusinessCard card) {
    final index = _cards.indexWhere((item) => item.id == card.id);
    if (index == -1) {
      _cards = [card, ..._cards];
    } else {
      _cards[index] = card;
    }
    _hasCards = _cards.isNotEmpty;
    _hasLoaded = true;
    notifyListeners();
  }

  /// Carte pro owner (espace professionnel).
  Future<BusinessCard?> ensureProfessionalCardForTeam(
    Team team, {
    User? owner,
  }) async {
    final existing = professionalCard;
    if (existing != null) return existing;

    final personal = personalCard;
    if (personal != null) {
      final created = await _cardsApi.createProfessionalFromPersonal(
        personal,
        teamId: team.id,
        company: team.name,
      );
      replaceCard(created);
      return created;
    }

    if (owner == null) return null;

    final created = await _cardsApi.createCard(
      firstName: owner.firstName,
      lastName: owner.lastName,
      email: owner.email,
      phone: owner.phone,
      kind: CardKind.professional,
      teamId: team.id,
      company: team.name,
    );
    replaceCard(created);
    return created;
  }

  /// Carte membre (espace membre) - distincte de la carte pro.
  Future<BusinessCard?> ensureMemberCardForTeam(
    Team team, {
    User? owner,
  }) async {
    final existing = memberCard(teamId: team.id);
    if (existing != null) return existing;

    // La carte a pu être créée côté serveur (accept invite) sans être en cache.
    await load(force: true);
    final afterReload = memberCard(teamId: team.id);
    if (afterReload != null) return afterReload;

    if (owner == null) return null;

    final personal = personalCard;
    try {
      final created = await _cardsApi.createCard(
        firstName: personal?.firstName ?? owner.firstName,
        lastName: personal?.lastName ?? owner.lastName,
        email: personal?.email ?? owner.email,
        phone: personal?.phone ?? owner.phone,
        jobTitle: personal?.jobTitle,
        kind: CardKind.member,
        teamId: team.id,
        company: team.name,
      );
      replaceCard(created);
      return created;
    } catch (_) {
      await load(force: true);
      return memberCard(teamId: team.id);
    }
  }
}
