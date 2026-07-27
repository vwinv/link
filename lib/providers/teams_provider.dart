import 'package:flutter/foundation.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';

class TeamsProvider extends ChangeNotifier {
  TeamsProvider({required TeamsApiService teamsApi}) : _teamsApi = teamsApi;

  final TeamsApiService _teamsApi;

  List<Team> _teams = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _currentUserId;
  bool _hasPendingInvites = false;

  List<Team> get teams => _teams;

  /// Équipe « principale » : équipe possédée en priorité, sinon première équipe membre.
  Team? get myTeam => ownedTeam ?? memberTeam;

  Team? get ownedTeam {
    for (final team in _teams) {
      if (team.isOwnedBy(_currentUserId)) return team;
    }
    return null;
  }

  /// Première équipe où l’utilisateur est membre (pas owner).
  Team? get memberTeam {
    for (final team in _teams) {
      if (!team.isOwnedBy(_currentUserId)) return team;
    }
    return null;
  }

  bool get hasTeam => _teams.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get hasPendingInvites => _hasPendingInvites;

  bool get isTeamOwner => ownedTeam != null;

  /// Accès espace membre : membre d’au moins une équipe (pas seulement owner).
  bool get canAccessMemberSpace => memberTeam != null;

  /// Afficher le CTA espace membre (accès ou invitation en attente).
  bool get shouldShowMemberSpaceCta =>
      canAccessMemberSpace || hasPendingInvites;

  Team? teamById(String? teamId) {
    if (teamId == null || teamId.isEmpty) return null;
    for (final team in _teams) {
      if (team.id == teamId) return team;
    }
    return null;
  }

  Team? teamForCard({String? teamId}) => teamById(teamId);

  void setCurrentUserId(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
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
      _teams = await _teamsApi.fetchMyTeams();
    } catch (_) {
      // Conserve les équipes déjà en mémoire ou en cache.
    }

    try {
      final invites = await _teamsApi.fetchMyInvitations();
      _hasPendingInvites = invites.isNotEmpty;
    } catch (_) {
      // Conserve l’état précédent.
    }

    _hasLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  void restoreFromCache(Team team) {
    _teams = [team];
    _hasLoaded = true;
    notifyListeners();
  }

  void setTeam(Team team) {
    final others = _teams.where((t) => t.id != team.id).toList();
    _teams = [team, ...others];
    _hasLoaded = true;
    notifyListeners();
  }

  void clearTeam() {
    _teams = const [];
    notifyListeners();
  }

  void reset() {
    _teams = const [];
    _isLoading = false;
    _hasLoaded = false;
    _currentUserId = null;
    _hasPendingInvites = false;
    _ongoingLoad = null;
    notifyListeners();
  }
}
