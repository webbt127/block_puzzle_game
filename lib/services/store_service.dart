import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:block_puzzle_game/services/logging_service.dart';
import 'package:shared_preferences.dart';

part 'store_service.g.dart';

class StoreService {
  static const String hideAdsId = 'hide_ads_temp';
  static const String premiumUpgradeId = 'premium_upgrade';
  static const List<String> _productIds = [hideAdsId, premiumUpgradeId];

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails>? _products;
  Set<String> _purchasedProductIds = {};
  static const String _purchaseStateKey = 'purchased_product_ids';
  bool _isAvailable = false;

  Future<void> initialize() async {
    await LoggingService.log('StoreService: Initializing...');
    await _loadPurchaseState();
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      await LoggingService.log('StoreService: Store not available');
      return;
    }

    await LoggingService.log('StoreService: Store is available');

    // Set up purchase stream listener
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        LoggingService.log('StoreService: Purchase stream error: $error');
      },
    );

    // Load products
    await loadProducts();

    // Check for existing purchases
    // try {
    //   await _inAppPurchase.restorePurchases();
    //   await LoggingService.log('StoreService: Restored purchases');
    // } catch (e) {
    //   await LoggingService.log('StoreService: Error restoring purchases: $e');
    // }
  }

  Future<void> loadProducts() async {
    await LoggingService.log('StoreService: Loading products...');

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds.toSet());

      if (response.error != null) {
        await LoggingService.log(
            'StoreService: Error loading products: ${response.error}');
        return;
      }

      if (response.productDetails.isEmpty) {
        await LoggingService.log('StoreService: No products found');
        return;
      }

      _products = response.productDetails;
      await LoggingService.log(
          'StoreService: Loaded ${_products?.length} products');

      for (var product in _products ?? []) {
        await LoggingService.log(
            '- ${product.id}: ${product.title} (${product.price})');
      }
    } catch (e) {
      await LoggingService.log('StoreService: Failed to load products: $e');
    }
  }

  Future<void> _handlePurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      await LoggingService.log(
          'StoreService: Processing purchase ${purchaseDetails.productID}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        await LoggingService.log('StoreService: Purchase pending');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        await LoggingService.log(
            'StoreService: Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await LoggingService.log('StoreService: Purchase successful');
        _purchasedProductIds.add(purchaseDetails.productID);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        await LoggingService.log('StoreService: Purchase completed');
      }
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    await LoggingService.log(
        'StoreService: Attempting to purchase ${product.id}');

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      await LoggingService.log('StoreService: Purchase initiated: $success');
      return success;
    } catch (e) {
      await LoggingService.log('StoreService: Purchase failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    await LoggingService.log('StoreService: Restoring purchases...');
    await _inAppPurchase.restorePurchases();
  }

  Future<bool> hasHideAds() async {
    await LoggingService.log('StoreService: Checking hide ads status');
    return _purchasedProductIds.contains(hideAdsId);
  }

  List<ProductDetails> get availableProducts {
    final available = (_products ?? [])
        .where((p) => !_purchasedProductIds.contains(p.id))
        .toList();
    LoggingService.log('StoreService: Getting available products:');
    LoggingService.log('- All products: ${_products?.length ?? 0}');
    LoggingService.log(
        '- Product IDs: ${_products?.map((p) => p.id).join(", ") ?? "none"}');
    LoggingService.log('- Purchased IDs: $_purchasedProductIds');
    LoggingService.log('- Available products: ${available.length}');
    return available;
  }

  List<ProductDetails> get purchasedProducts {
    final purchased = (_products ?? [])
        .where((p) => _purchasedProductIds.contains(p.id))
        .toList();
    LoggingService.log('StoreService: Getting purchased products:');
    LoggingService.log('- All products: ${_products?.length ?? 0}');
    LoggingService.log(
        '- Product IDs: ${_products?.map((p) => p.id).join(", ") ?? "none"}');
    LoggingService.log('- Purchased IDs: $_purchasedProductIds');
    LoggingService.log('- Purchased products: ${purchased.length}');
    return purchased;
  }

  Future<void> _loadPurchaseState() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedIds = prefs.getStringList(_purchaseStateKey) ?? [];
    _purchasedProductIds = Set<String>.from(purchasedIds);
    await LoggingService.log('StoreService: Loaded purchase state: $_purchasedProductIds');
  }

  Future<void> _savePurchaseState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_purchaseStateKey, _purchasedProductIds.toList());
    await LoggingService.log('StoreService: Saved purchase state: $_purchasedProductIds');
  }

  void dispose() {
    _subscription?.cancel();
  }
}

@riverpod
StoreService storeService(Ref ref) {
  final service = StoreService();
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
Future<void> initializeStore(Ref ref) async {
  final service = ref.watch(storeServiceProvider);
  await service.initialize();
}

@riverpod
Future<List<ProductDetails>> availableProducts(Ref ref) async {
  final service = ref.watch(storeServiceProvider);
  await ref.watch(initializeStoreProvider.future);
  await LoggingService.log('AvailableProducts Provider: Getting products');
  final products = service.availableProducts;
  await LoggingService.log(
      'AvailableProducts Provider: Found ${products.length} products');
  return products;
}

@riverpod
Future<List<ProductDetails>> purchasedProducts(Ref ref) async {
  final service = ref.watch(storeServiceProvider);
  await ref.watch(initializeStoreProvider.future);
  await LoggingService.log('PurchasedProducts Provider: Getting products');
  final products = service.purchasedProducts;
  await LoggingService.log(
      'PurchasedProducts Provider: Found ${products.length} products');
  return products;
}

@riverpod
Future<bool> hasHideAds(Ref ref) async {
  final service = ref.watch(storeServiceProvider);
  await ref.watch(initializeStoreProvider.future);
  await LoggingService.log('HasHideAds Provider: Checking status');
  final hasAds = await service.hasHideAds();
  await LoggingService.log('HasHideAds Provider: Result: $hasAds');
  return hasAds;
}
