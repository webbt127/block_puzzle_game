import 'package:block_puzzle_game/providers/feedback_providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/store_service.dart';
import '../services/logging_service.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize store
    ref.read(initializeStoreProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    final feedbackManager = ref.read(settingsFeedbackProvider);
    feedbackManager.playFeedback();
    ref.invalidate(hasHideAdsProvider);
    await Future.wait([
      ref.refresh(availableProductsProvider.future),
      ref.refresh(purchasedProductsProvider.future),
    ]);
  }

  Widget _buildProductList(List<ProductDetails> products,
      {bool isPurchased = false}) {
    LoggingService.log('Building product list. isPurchased: $isPurchased, products: ${products.length}');
    for (var product in products) {
      LoggingService.log('- ${product.id} (${product.title})');
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).cardColor,
          child: ListTile(
            title: Text(
              product.title,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              product.description,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            trailing: isPurchased
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _handlePurchase(product),
                    child: Text(product.price),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handlePurchase(ProductDetails product) async {
    final feedbackManager = ref.read(settingsFeedbackProvider);
    feedbackManager.playFeedback();
    try {
      final success = await ref.read(storeServiceProvider).buyProduct(product);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase initiated!')),
        );
        _refreshProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(hasHideAdsProvider);
    final feedbackManager = ref.watch(settingsFeedbackProvider);

    LoggingService.log('StoreScreen: Building screen');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          'premium_features'.tr(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            feedbackManager.playFeedback();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.restore,
              color: Colors.white,
            ),
            onPressed: () async {
              feedbackManager.playFeedback();
              try {
                await ref.read(storeServiceProvider).restorePurchases();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Restore initiated')),
                  );
                  _refreshProducts();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restore failed: $e')),
                  );
                }
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          tabs: [
            Tab(text: 'available'.tr()),
            Tab(text: 'purchased'.tr()),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Available Products Tab
            FutureBuilder<List<ProductDetails>>(
              future: ref.watch(availableProductsProvider.future),
              builder: (context, snapshot) {
                LoggingService.log('StoreScreen: Building available products tab');
                LoggingService.log('- Connection state: ${snapshot.connectionState}');
                LoggingService.log('- Has error: ${snapshot.hasError}');
                LoggingService.log('- Error: ${snapshot.error}');
                LoggingService.log('- Has data: ${snapshot.hasData}');
                LoggingService.log('- Data length: ${snapshot.data?.length ?? 0}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No available products to purchase',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                }
                return _buildProductList(snapshot.data!);
              },
            ),
            // Purchased Products Tab
            FutureBuilder<List<ProductDetails>>(
              future: ref.watch(purchasedProductsProvider.future),
              builder: (context, snapshot) {
                LoggingService.log('StoreScreen: Building purchased products tab');
                LoggingService.log('- Connection state: ${snapshot.connectionState}');
                LoggingService.log('- Has error: ${snapshot.hasError}');
                LoggingService.log('- Error: ${snapshot.error}');
                LoggingService.log('- Has data: ${snapshot.hasData}');
                LoggingService.log('- Data length: ${snapshot.data?.length ?? 0}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No purchased products',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                }
                return _buildProductList(snapshot.data!, isPurchased: true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
