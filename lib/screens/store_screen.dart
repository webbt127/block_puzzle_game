import 'package:block_puzzle_game/providers/feedback_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  static const String entitlementID = 'premium';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    final feedbackManager = ref.read(settingsFeedbackProvider);
    feedbackManager.playFeedback();
    ref.invalidate(isSubscribedProvider);
    ref.invalidate(hasHideAdsProvider);
    await Future.wait([
      ref.refresh(productsProvider.future),
      ref.refresh(purchasedProductsProvider.future),
    ]);
  }

  Widget _buildProductList(List<StoreProduct> products,
      {bool isPurchased = false}) {
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
                    child: Text(product.priceString),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handlePurchase(StoreProduct product) async {
    final feedbackManager = ref.read(settingsFeedbackProvider);
    feedbackManager.playFeedback();
    try {
      final result =
          await ref.read(revenueCatServiceProvider).purchaseProduct(product);
      if (result.entitlements.all[entitlementID]?.isActive ?? false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase successful!')),
          );
          _refreshProducts();
        }
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
    ref.watch(isSubscribedProvider);
    ref.watch(hasHideAdsProvider);
    final feedbackManager = ref.watch(settingsFeedbackProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Premium Features',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            feedbackManager.playFeedback();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.restore,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () async {
              feedbackManager.playFeedback();
              try {
                await ref.read(revenueCatServiceProvider).restorePurchases();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Purchases restored successfully')),
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
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Purchased'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Available Products Tab
            FutureBuilder<List<StoreProduct>>(
              future: ref.watch(productsProvider.future),
              builder: (context, snapshot) {
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
            FutureBuilder<List<StoreProduct>>(
              future: ref.watch(purchasedProductsProvider.future),
              builder: (context, snapshot) {
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
