import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'revenue_cat_service.g.dart';

class RevenueCatService {
  bool _isInitialized = false;

  Future<void> init(String apiKey) async {
    try {
      if (_isInitialized) {
        print('RevenueCat: Already initialized');
        return;
      }
      print(
          'RevenueCat: Initializing with API key: ${apiKey.substring(0, 5)}...');
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isInitialized = true;
      print('RevenueCat: Successfully initialized');
    } catch (e, stackTrace) {
      print('RevenueCat: Initialization failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> checkSubscriptionStatus() async {
    try {
      print('RevenueCat: Checking subscription status...');
      final customerInfo = await Purchases.getCustomerInfo();
      final isActive = customerInfo.entitlements.active.isNotEmpty;
      print('RevenueCat: Subscription status - Active: $isActive');
      print(
          'RevenueCat: Active entitlements: ${customerInfo.entitlements.active.keys}');
      return isActive;
    } catch (e, stackTrace) {
      print('RevenueCat: Subscription check failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<List<StoreProduct>> getProducts() async {
    try {
      print('RevenueCat: Fetching products directly...');
      final productIds = ['hide_ads_temp', 'premium_upgrade'];
      final customerInfo = await Purchases.getCustomerInfo();

      print('RevenueCat: Requesting products with IDs: $productIds');
      final products = await Purchases.getProducts(
        productIds,
        type: PurchaseType.inapp,
      );
      print('RevenueCat: Fetched ${products.length} products');

      // Filter out products that are already purchased
      final filteredProducts = products.where((product) {
        // Check subscriptions in entitlements
        final isEntitled = customerInfo.entitlements.active.values.any(
            (entitlement) =>
                entitlement.productIdentifier == product.identifier);

        // Check one-time purchases
        final isPurchased = customerInfo.nonSubscriptionTransactions.any(
            (transaction) =>
                transaction.productIdentifier == product.identifier);

        return !isEntitled && !isPurchased;
      }).toList();

      print('RevenueCat: Found ${filteredProducts.length} available products:');
      for (var product in filteredProducts) {
        print('- Product ID: ${product.identifier}');
        print('  Title: ${product.title}');
        print('  Description: ${product.description}');
        print('  Price: ${product.priceString}');
      }

      return filteredProducts;
    } catch (e, stackTrace) {
      print('RevenueCat: Failed to fetch products');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CustomerInfo> purchaseProduct(StoreProduct product) async {
    try {
      print('RevenueCat: Attempting to purchase product ${product.identifier}');
      final result = await Purchases.purchaseStoreProduct(product);
      print('RevenueCat: Purchase successful');
      print(
          'RevenueCat: Active entitlements: ${result.entitlements.active.keys}');
      return result;
    } catch (e, stackTrace) {
      print('RevenueCat: Purchase failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    try {
      print('RevenueCat: Attempting to restore purchases...');
      final result = await Purchases.restorePurchases();
      print('RevenueCat: Restore successful');
      print(
          'RevenueCat: Active entitlements: ${result.entitlements.active.keys}');
      return result;
    } catch (e, stackTrace) {
      print('RevenueCat: Restore failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> hasHideAds() async {
    try {
      print('RevenueCat: Checking hide_ads_bb status...');
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if the product is purchased
      final hasHideAds = customerInfo.nonSubscriptionTransactions
          .any((transaction) => transaction.productIdentifier == 'hide_ads_temp');

      print('RevenueCat: Hide Ads Status: $hasHideAds');
      return hasHideAds;
    } catch (e) {
      print('RevenueCat: Failed to check hide_ads_bb status: $e');
      return false;
    }
  }

  Future<List<StoreProduct>> getPurchasedProducts() async {
    try {
      print('RevenueCat: Fetching purchased products...');
      final productIds = ['hide_ads_temp', 'premium_upgrade'];
      final customerInfo = await Purchases.getCustomerInfo();
      final products = await Purchases.getProducts(productIds);

      // Filter to only include purchased products
      final purchasedProducts = products.where((product) {
        // Check subscriptions in entitlements
        final isEntitled = customerInfo.entitlements.active.values.any(
            (entitlement) =>
                entitlement.productIdentifier == product.identifier);

        // Check one-time purchases
        final isPurchased = customerInfo.nonSubscriptionTransactions.any(
            (transaction) =>
                transaction.productIdentifier == product.identifier);

        return isEntitled || isPurchased;
      }).toList();

      print('RevenueCat: Found ${purchasedProducts.length} purchased products');
      return purchasedProducts;
    } catch (e, stackTrace) {
      print('RevenueCat: Failed to fetch purchased products');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

@riverpod
RevenueCatService revenueCatService(Ref ref) {
  return RevenueCatService();
}

@riverpod
Future<bool> isSubscribed(Ref ref) async {
  return await ref.read(revenueCatServiceProvider).checkSubscriptionStatus();
}

@riverpod
Future<bool> hasHideAds(Ref ref) async {
  return await ref.watch(revenueCatServiceProvider).hasHideAds();
}

@riverpod
Future<List<StoreProduct>> products(Ref ref) async {
  return await ref.read(revenueCatServiceProvider).getProducts();
}

@riverpod
Future<List<StoreProduct>> purchasedProducts(Ref ref) async {
  return await ref.read(revenueCatServiceProvider).getPurchasedProducts();
}
