import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/subscriptions/models/user_subscription.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';

class AppleIapService {
  AppleIapService(this._api);

  static const _storeTimeout = Duration(seconds: 20);
  static const _queryTimeout = Duration(seconds: 45);
  static const _sheetTimeout = Duration(seconds: 120);

  final SubscriptionsApiService _api;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<PurchaseDetails>? _waitForProduct;
  String? _waitingProductId;
  bool _iosDelegateSet = false;

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> ensureStarted() async {
    if (_purchaseSub != null) return;
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object error) {
        debugPrint('Apple IAP stream error: $error');
      },
    );
    await _setIosDelegate();
  }

  Future<void> dispose() async {
    if (_iosDelegateSet) {
      try {
        final addition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await addition.setDelegate(null);
      } catch (_) {}
      _iosDelegateSet = false;
    }
    await _purchaseSub?.cancel();
    _purchaseSub = null;
  }

  Future<Map<String, String>> priceLabels(Set<String> productIds) async {
    if (!isSupported || productIds.isEmpty) return {};
    await ensureStarted();
    final available = await _isStoreAvailable();
    if (!available) return {};
    final query = await _queryProducts(productIds);
    return {
      for (final product in query.productDetails) product.id: product.price,
    };
  }

  Future<UserSubscription> purchase({
    required String productId,
    required String offerSlug,
    required String billingType,
    String? teamId,
    int? seats,
  }) async {
    try {
      return await _purchaseInternal(
        productId: productId,
        offerSlug: offerSlug,
        billingType: billingType,
        teamId: teamId,
        seats: seats,
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<UserSubscription> _purchaseInternal({
    required String productId,
    required String offerSlug,
    required String billingType,
    String? teamId,
    int? seats,
  }) async {
    await ensureStarted();
    final available = await _isStoreAvailable();
    if (!available) {
      throw ApiException(_storeUnreachableMessage);
    }

    final query = await _queryProduct(productId);
    if (query.productDetails.isEmpty) {
      if (query.error?.code == 'storekit_no_response') {
        throw ApiException(_storeUnreachableMessage);
      }
      throw ApiException(_productMissingMessage(productId));
    }

    final product = query.productDetails.first;
    final completer = Completer<PurchaseDetails>();
    _waitingProductId = product.id;
    _waitForProduct = completer;

    final launched = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!launched) {
      _clearWait();
      throw ApiException('Achat Apple annulé.');
    }

    final details = await completer.future.timeout(
      _sheetTimeout,
      onTimeout: () {
        _clearWait();
        throw ApiException(_sheetTimeoutMessage);
      },
    );

    return _finish(details, offerSlug, billingType, teamId, seats);
  }

  Future<UserSubscription?> restore({
    String? offerSlug,
    String? billingType,
    String? teamId,
    int? seats,
  }) async {
    await ensureStarted();
    final available = await _isStoreAvailable();
    if (!available) return null;

    final completer = Completer<PurchaseDetails>();
    _waitingProductId = null;
    _waitForProduct = completer;
    await _iap.restorePurchases().timeout(
      _storeTimeout,
      onTimeout: () {
        _clearWait();
        throw ApiException(_storeUnreachableMessage);
      },
    );

    PurchaseDetails? details;
    try {
      details = await completer.future.timeout(const Duration(seconds: 20));
    } on TimeoutException {
      _clearWait();
      return null;
    } on ApiException {
      rethrow;
    }

    if (details.status == PurchaseStatus.canceled) return null;
    return _finish(
      details,
      offerSlug ?? '',
      billingType ?? '',
      teamId,
      seats,
    );
  }

  Future<UserSubscription> _finish(
    PurchaseDetails details,
    String offerSlug,
    String billingType,
    String? teamId,
    int? seats,
  ) async {
    if (details.status == PurchaseStatus.canceled) {
      throw ApiException('Achat Apple annulé.');
    }
    if (details.status == PurchaseStatus.error) {
      throw ApiException(
        _friendlyStoreError(details.error) ,
      );
    }
    if (details.status != PurchaseStatus.purchased &&
        details.status != PurchaseStatus.restored) {
      throw ApiException('Achat Apple incomplet.');
    }

    final signedTransaction = _signedTransaction(details);
    if (signedTransaction.isEmpty) {
      throw ApiException('Preuve d’achat Apple manquante.');
    }

    try {
      final subscription = await _api.verifyAppleIap(
        signedTransaction: signedTransaction,
        offerSlug: offerSlug.isEmpty ? null : offerSlug,
        billingType: billingType.isEmpty ? null : billingType,
        teamId: teamId,
        seats: seats,
      );
      if (details.pendingCompletePurchase) {
        await _iap.completePurchase(details);
      }
      return subscription;
    } catch (error) {
      if (details.pendingCompletePurchase &&
          error is ApiException &&
          (error.message.contains('déjà lié') ||
              error.message.contains('expiré'))) {
        await _iap.completePurchase(details);
      }
      rethrow;
    }
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      final completer = _waitForProduct;
      if (completer != null && !completer.isCompleted) {
        if (_waitingProductId != null &&
            purchase.productID != _waitingProductId) {
          continue;
        }
        _clearWait();
        completer.complete(purchase);
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        unawaited(() async {
          try {
            await _finish(purchase, '', '', null, null);
          } catch (error) {
            debugPrint('Apple IAP transaction différée: $error');
          }
        }());
      } else if (purchase.pendingCompletePurchase) {
        unawaited(_iap.completePurchase(purchase));
      }
    }
  }

  void _clearWait() {
    _waitForProduct = null;
    _waitingProductId = null;
  }

  Future<void> _setIosDelegate() async {
    if (!isSupported || _iosDelegateSet) return;
    try {
      final addition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await addition.setDelegate(_DropOnePaymentQueueDelegate());
      _iosDelegateSet = true;
    } catch (error) {
      debugPrint('Apple IAP delegate: $error');
    }
  }

  Future<bool> _isStoreAvailable() async {
    try {
      return await _iap.isAvailable().timeout(_storeTimeout);
    } catch (error) {
      debugPrint('Apple IAP isAvailable: $error');
      return false;
    }
  }

  Future<ProductDetailsResponse> _queryProduct(String productId) {
    return _queryProducts({productId});
  }

  Future<ProductDetailsResponse> _queryProducts(Set<String> productIds) async {
    ProductDetailsResponse? last;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        last = await _iap
            .queryProductDetails(productIds)
            .timeout(_queryTimeout);
        if (last.productDetails.isNotEmpty) return last;
      } catch (error) {
        debugPrint('Apple IAP queryProductDetails: $error');
        last = ProductDetailsResponse(
          productDetails: const [],
          notFoundIDs: productIds.toList(),
          error: IAPError(
            source: 'app_store',
            code: 'storekit_no_response',
            message: error.toString(),
          ),
        );
      }
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
    return last ??
        ProductDetailsResponse(
          productDetails: const [],
          notFoundIDs: productIds.toList(),
        );
  }

  String _signedTransaction(PurchaseDetails details) {
    final server = details.verificationData.serverVerificationData.trim();
    if (server.isNotEmpty) return server;
    return details.verificationData.localVerificationData.trim();
  }

  static String get _storeUnreachableMessage {
    if (kDebugMode) {
      return 'L’App Store ne répond pas. Pour tester en local : ouvrir ios/Runner.xcworkspace dans Xcode, Scheme Runner → Options → StoreKit Configuration = DropOne.storekit, puis Run. Pas Flutter Run.';
    }
    return 'L’App Store met trop de temps à répondre. Vérifiez la connexion, puis Réglages → App Store → Compte Sandbox (compte testeur), et réessayez.';
  }

  static String get _sheetTimeoutMessage {
    if (kDebugMode) {
      return 'La fenêtre Apple ne s’est pas ouverte. Lancez l’app depuis Xcode avec DropOne.storekit.';
    }
    return 'La fenêtre de paiement Apple ne s’est pas ouverte. Réessayez, ou connectez un compte Sandbox dans Réglages → App Store.';
  }

  static String _productMissingMessage(String productId) {
    if (kDebugMode) {
      return 'Produit $productId introuvable. Sur simulateur, lancez depuis Xcode avec DropOne.storekit.';
    }
    return 'Produit introuvable sur l’App Store ($productId). Dans App Store Connect : créez un abonnement avec exactement cet identifiant, ajoutez une localisation, signez le contrat Paid Apps. TestFlight n’utilise pas DropOne.storekit.';
  }

  String _friendlyStoreError(IAPError? error) {
    final code = error?.code ?? '';
    final message = (error?.message ?? '').toLowerCase();
    if (code == 'storekit_no_response' ||
        message.contains('failed to get response from platform')) {
      return _storeUnreachableMessage;
    }
    if (error?.message != null && error!.message.isNotEmpty) {
      return error.message;
    }
    return _storeUnreachableMessage;
  }
}

class _DropOnePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
