import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/subscriptions/models/user_subscription.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionsProvider extends ChangeNotifier {
  SubscriptionsProvider({required SubscriptionsApiService subscriptionsApi})
      : _subscriptionsApi = subscriptionsApi {
    _restoreFromCache();
  }

  static const _cacheKey = 'user_subscription_cache';

  final SubscriptionsApiService _subscriptionsApi;

  UserSubscription? _subscription;
  bool _isLoading = false;
  Future<void>? _loadingFuture;

  UserSubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _subscription?.isActive ?? false;
  OfferEntitlements get entitlements =>
      _subscription?.entitlements ?? OfferEntitlements.none;
  bool get hasTeamSubscription =>
      hasActiveSubscription && entitlements.hasTeamAccess;
  bool get canCustomizeCards => entitlements.canCustomize;
  bool get hasPortfolioAccess => entitlements.hasPortfolio;
  bool get hasWalletAccess => entitlements.hasWallet;
  bool get hasAnalyticsAccess => entitlements.hasAnalytics;
  bool get hasVisitorInsightsAccess => entitlements.hasVisitorInsights;
  bool get hasSocialLinksAccess => entitlements.hasSocialLinks;

  /// Droits effectifs pour une carte (offre équipe du owner si carte membre).
  OfferEntitlements entitlementsForCard(
    BusinessCard card, {
    Team? team,
  }) {
    if (card.kind == CardKind.member) {
      final teamEntitlements = team?.entitlements;
      if (teamEntitlements != null) {
        return teamEntitlements;
      }
    }
    return entitlements;
  }

  bool canCustomizeCard(BusinessCard card, {Team? team}) =>
      entitlementsForCard(card, team: team).canCustomize;

  bool canUseWalletFor(BusinessCard card, {Team? team}) =>
      entitlementsForCard(card, team: team).hasWallet;

  bool canViewAnalyticsFor(BusinessCard card, {Team? team}) =>
      entitlementsForCard(card, team: team).hasAnalytics;

  bool canViewVisitorsFor(BusinessCard card, {Team? team}) =>
      entitlementsForCard(card, team: team).hasVisitorInsights;

  bool canEditSocialLinksFor(BusinessCard card, {Team? team}) =>
      entitlementsForCard(card, team: team).hasSocialLinks;

  Future<void> refresh() async {
    if (_loadingFuture != null) {
      await _loadingFuture;
      return;
    }

    _loadingFuture = _loadFromApi();
    try {
      await _loadingFuture;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<void> _loadFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final subscription = await _subscriptionsApi.fetchMySubscription();
      await _applySubscription(subscription);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        await _applySubscription(null);
      }
    } catch (_) {
      // Conserve le cache local en cas d'erreur réseau.
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _restoreFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return;

    try {
      final subscription = UserSubscription.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!subscription.isActive) {
        await prefs.remove(_cacheKey);
        return;
      }

      _subscription = subscription;
      notifyListeners();
    } catch (_) {
      await prefs.remove(_cacheKey);
    }
  }

  Future<void> _applySubscription(UserSubscription? subscription) async {
    _subscription = subscription?.isActive == true ? subscription : null;

    final prefs = await SharedPreferences.getInstance();
    if (_subscription == null) {
      await prefs.remove(_cacheKey);
      return;
    }

    await prefs.setString(_cacheKey, jsonEncode(_subscription!.toJson()));
  }

  void setSubscription(UserSubscription subscription) {
    _subscription = subscription.isActive ? subscription : null;
    notifyListeners();
    _persistSubscription();
  }

  Future<void> _persistSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    if (_subscription == null) {
      await prefs.remove(_cacheKey);
      return;
    }

    await prefs.setString(_cacheKey, jsonEncode(_subscription!.toJson()));
  }

  Future<void> clear() async {
    _subscription = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    notifyListeners();
  }
}
