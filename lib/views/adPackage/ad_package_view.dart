import 'package:flutter/material.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:olx_clone/models/ad_package.dart';
import 'package:olx_clone/providers/ad_provider.dart';
import 'package:olx_clone/models/product.dart';

class AdPackageView extends StatefulWidget {
  const AdPackageView({super.key});

  @override
  State<AdPackageView> createState() => _AdPackageViewState();
}

class _AdPackageViewState extends State<AdPackageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdProvider>();
      provider.fetchAdPackages();
      provider.fetchCart();
      provider.fetchMyProducts();
    });
  }

  void _navigateToCart(BuildContext context) {
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Paket Iklan',
          style: TextStyle(
            color: Color(0xFF002F34),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF002F34),
        elevation: 1,
        shadowColor: Colors.grey.withAlpha(20),
        actions: [
          Consumer<AdProvider>(
            builder: (context, provider, child) {
              return Center(
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFF002F34),
                        size: 26,
                      ),
                      onPressed: () => _navigateToCart(context),
                    ),
                    if (provider.cartItemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5636),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.cartItemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AdProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF002F34)),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchAdPackages(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002F34),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAdPackages(),
            color: const Color(0xFF002F34),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.packages.length,
              itemBuilder: (context, index) {
                final package = provider.packages[index];
                return _buildPackageCard(package, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(AdPackage package, AdProvider provider) {
    final titleParts = package.name.split('+').map((e) => e.trim()).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (int i = 0; i < titleParts.length; i++) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      titleParts[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (i < titleParts.length - 1)
                    const Text(
                      ' + ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF002F34),
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (package.description.isNotEmpty)
              Text(
                package.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (package.description.isNotEmpty) const SizedBox(height: 16),
            if (package.features.isNotEmpty) ...[
              ...package.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: Color(0xFF00A49F),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature.featureType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF002F34),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp ${_formatPrice(package.price)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002F34),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showProductSelectionDialog(context, package, provider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A77FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Pilih',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProductSelectionDialog(
    BuildContext context,
    AdPackage package,
    AdProvider provider,
  ) async {
    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).colors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Pilih Iklan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Consumer<AdProvider>(
                    builder: (context, adProvider, child) {
                      if (adProvider.isLoadingMyProducts) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      if (adProvider.myProducts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Text(
                            'Anda tidak punya iklan untuk dipromosikan.',
                            style: TextStyle(
                              color: Color(0xFF002F34),
                              fontSize: 15,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 220,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: adProvider.myProducts.length,
                            separatorBuilder:
                                (context, i) =>
                                    Divider(color: Colors.grey[300], height: 1),
                            itemBuilder: (context, index) {
                              final product = adProvider.myProducts[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                title: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF002F34),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onTap: () {
                                  Navigator.of(dialogContext).pop(product);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, right: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedProduct != null) {
      await provider.addToCart(package, selectedProduct.id);
      if (!mounted) return;
      if (provider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${package.name} ditambahkan untuk ${selectedProduct.title}',
            ),
            backgroundColor: const Color(0xFF00A49F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }
}
