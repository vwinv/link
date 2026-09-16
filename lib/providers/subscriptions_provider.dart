import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/subscriptions/models/payment_config.dart';
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
  bool _hideInAppPayments = false;
  bool _isLoading = false;
  Future<void>? _loadingFuture;

  /// iOS + HIDE_IN_APP_PAYMENTS=true : accès complet pour la review Apple.
  bool get isAppleReviewFullAccess =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      _hideInAppPayments;

  /// Masque les boutons / bandeaux « Passer Premium » (review Apple).
  bool get hidePremiumUpsells => isAppleReviewFullAccess;

  bool get hideInAppPayments => _hideInAppPayments;

  UserSubscription? get subscription {
    if (isAppleReviewFullAccess) {
      return _subscription?.isActive == true ? _subscription : _syntheticReviewSubscription;
    }
    return _subscription?.isActive == true ? _subscription : null;
  }

  bool get isLoading => _isLoading;
  bool get hasActiveSubscription =>
      isAppleReviewFullAccess || subscription != null;
  OfferEntitlements get entitlements =>
      isAppleReviewFullAccess
          ? OfferEntitlements.fullAccess
          : (subscription?.entitlements ?? OfferEntitlements.none);
  bool get hasTeamSubscription =>
      isAppleReviewFullAccess ||
      (hasActiveSubscription && entitlements.hasTeamAccess);
  bool get canCustomizeCards => entitlements.canCustomize;
  bool get hasPortfolioAccess => entitlements.hasPortfolio;
  bool get hasWalletAccess => entitlements.hasWallet;
  bool get hasAnalyticsAccess => entitlements.hasAnalytics;
  bool get hasVisitorInsightsAccess => entitlements.hasVisitorInsights;
  bool get hasSocialLinksAccess => entitlements.hasSocialLinks;

  /// Droits effectifs pour une carte :
  /// perso → offre perso ; pro / membre → uniquement une offre équipe.
  OfferEntitlements entitlementsForCard(
    BusinessCard card, {
    Team? team,
  }) {
    if (isAppleReviewFullAccess) {
      return OfferEntitlements.fullAccess;
    }

    if (card.kind == CardKind.member) {
      final teamEntitlements = team?.entitlements;
      if (teamEntitlements != null && teamEntitlements.hasTeamAccess) {
        return teamEntitlements;
      }
      return OfferEntitlements.none;
    }

    if (card.kind == CardKind.professional) {
      if (!hasTeamSubscription) return OfferEntitlements.none;
      return entitlements;
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

  /// Carte pro / membre : bloquée sans offre équipe valide.
  bool canUseTeamLinkedCard(BusinessCard card, {Team? team}) {
    if (isAppleReviewFullAccess) return true;
    if (card.kind != CardKind.professional && card.kind != CardKind.member) {
      return true;
    }
    return entitlementsForCard(card, team: team).hasTeamAccess;
  }

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

  /// Charge uniquement le flag paiements (utile avant / pendant création de carte).
  Future<void> ensurePaymentConfigLoaded() async {
    if (_hideInAppPayments) return;
    try {
      final paymentConfig = await _subscriptionsApi.fetchPaymentConfig();
      if (_hideInAppPayments == paymentConfig.hideInAppPayments) return;
      _hideInAppPayments = paymentConfig.hideInAppPayments;
      notifyListeners();
    } catch (_) {
      // Conserve l’état courant.
    }
  }

  Future<void> _loadFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _subscriptionsApi.fetchMySubscription(),
        _subscriptionsApi.fetchPaymentConfig(),
      ]);
      final subscription = results[0] as UserSubscription?;
      final paymentConfig = results[1] as PaymentConfig;
      _hideInAppPayments = paymentConfig.hideInAppPayments;
      await _applySubscription(subscription);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        try {
          final paymentConfig = await _subscriptionsApi.fetchPaymentConfig();
          _hideInAppPayments = paymentConfig.hideInAppPayments;
          await _applySubscription(null);
        } catch (_) {
          await _applySubscription(null);
        }
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
    _hideInAppPayments = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    notifyListeners();
  }

  static final UserSubscription _syntheticReviewSubscription = UserSubscription(
    id: 'apple-review-full-access',
    status: 'ACTIVE',
    billingPeriod: 'MONTHLY',
    planName: 'DropOne Review',
    planSlug: 'apple-review',
    offerTitle: 'DropOne Review',
    offerSlug: 'apple-review',
    billingType: 'MONTHLY',
    entitlements: OfferEntitlements.fullAccess,
  );
}
