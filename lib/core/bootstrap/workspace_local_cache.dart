import 'dart:convert';

import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class WorkspaceLocalCache {
  static String _cardsKey(String userId) => 'workspace_cards_$userId';
  static String _teamKey(String userId) => 'workspace_team_$userId';

  static Future<void> hydrate({
    required String userId,
    required CardsProvider cards,
    required TeamsProvider teams,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final cardsJson = prefs.getString(_cardsKey(userId));
    if (cardsJson != null) {
      final decoded = jsonDecode(cardsJson);
      if (decoded is List) {
        final restored = <BusinessCard>[];
        for (final item in decoded) {
          if (item is! Map) continue;
          try {
            restored.add(
              BusinessCard.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (_) {
            // Ignore malformed cache entries.
          }
        }
        cards.restoreFromCache(restored);
      }
    }

    final teamJson = prefs.getString(_teamKey(userId));
    if (teamJson != null) {
      try {
        final decoded = jsonDecode(teamJson);
        if (decoded is Map) {
          teams.restoreFromCache(
            Team.fromJson(Map<String, dynamic>.from(decoded)),
          );
        }
      } catch (_) {
        // Ignore malformed cache entry.
      }
    }
  }

  static Future<void> persist({
    required String userId,
    required CardsProvider cards,
    required TeamsProvider teams,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (cards.cards.isNotEmpty) {
      final encoded = jsonEncode(cards.cards.map((card) => card.toJson()).toList());
      await prefs.setString(_cardsKey(userId), encoded);
    }

    final team = teams.myTeam;
    if (team != null) {
      await prefs.setString(_teamKey(userId), jsonEncode(team.toJson()));
    } else {
      await prefs.remove(_teamKey(userId));
    }
  }

  static Future<void> clearForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cardsKey(userId));
    await prefs.remove(_teamKey(userId));
  }
}
