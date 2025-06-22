import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/product_provider.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/models/category.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:intl/intl.dart';

class MyAdsView extends StatefulWidget {
  const MyAdsView({super.key});

  @override
  State<MyAdsView> createState() => _MyAdsViewState();
}

class _MyAdsViewState extends State<MyAdsView> with TickerProviderStateMixin {
  List<Product> _userProducts = [];
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  TabController? _tabController;
  bool _isListenerAdded = false;
  ProductProvider? _productProvider;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isListenerAdded) {
      _productProvider = context.read<ProductProvider>();
      _productProvider!.addListener(_onProductProviderChange);
      _isListenerAdded = true;
      // Load data after setting up the provider
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    if (_isListenerAdded && _productProvider != null) {
      _productProvider!.removeListener(_onProductProviderChange);
    }
    super.dispose();
  }

  void _onProductProviderChange() {
    if (!mounted) return;

    if (_productProvider != null && _productProvider!.shouldRefreshMyAds) {
      _productProvider!.clearRefreshFlag();
      Future.microtask(() {
        if (mounted) {
          _loadData();
        }
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted || _productProvider == null) return;

    setState(() {
      _isLoading = true;
    });

    final userProducts = await _productProvider!.getUserProducts(isMyAds: true);
    final favoriteProducts = await _productProvider!.getFavoriteProducts();

    if (mounted) {
      setState(() {
        _userProducts = userProducts;
        _favoriteProducts = favoriteProducts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: theme.colors.primary,
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                ),
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                snap: false,
                elevation: 0.5,
                backgroundColor: theme.colors.surface,
                surfaceTintColor: theme.colors.surface,
                title:
                    innerBoxIsScrolled
                        ? Text(
                          'Iklan Saya',
                          style: theme.textStyle.titleLarge.copyWith(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        )
                        : null,
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 60,
                  ),
                  background: Container(
                    color: theme.colors.surface,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 16,
                        right: 16,
                        bottom: 60,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: deviceHeight * 0.04,
                            child: Image.asset(
                              'assets/images/OLX-LOGO-BLUE.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'OLX',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Iklan Saya',
                            style: AppTheme.of(context).textStyle.titleLarge
                                .copyWith(color: Colors.black),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom:
                    _tabController != null
                        ? PreferredSize(
                          preferredSize: Size.fromHeight(deviceHeight * 0.07),
                          child: Container(
                            color: theme.colors.surface,
                            padding: EdgeInsets.symmetric(
                              horizontal: deviceWidth * 0.04,
                              vertical: deviceHeight * 0.01,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _tabController!.animateTo(0),
                                    child: AnimatedBuilder(
                                      animation: _tabController!,
                                      builder: (context, child) {
                                        final isSelected =
                                            _tabController!.index == 0;
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: deviceHeight * 0.015,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? AppTheme.of(
                                                      context,
                                                    ).colors.primary
                                                    : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow:
                                                isSelected
                                                    ? [
                                                      BoxShadow(
                                                        color: AppTheme.of(
                                                              context,
                                                            ).colors.primary
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'IKLAN',
                                              style: theme.textStyle.titleSmall
                                                  .copyWith(
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        deviceWidth * 0.035,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: deviceWidth * 0.03),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _tabController!.animateTo(1),
                                    child: AnimatedBuilder(
                                      animation: _tabController!,
                                      builder: (context, child) {
                                        final isSelected =
                                            _tabController!.index == 1;
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: deviceHeight * 0.015,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? AppTheme.of(
                                                      context,
                                                    ).colors.primary
                                                    : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow:
                                                isSelected
                                                    ? [
                                                      BoxShadow(
                                                        color: AppTheme.of(
                                                              context,
                                                            ).colors.primary
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'FAVORIT',
                                              style: theme.textStyle.titleSmall
                                                  .copyWith(
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        deviceWidth * 0.035,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : null,
              ),
            ];
          },
          body:
              _tabController != null
                  ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList(_userProducts),
                      _buildProductList(_favoriteProducts, isFavorite: true),
                    ],
                  )
                  : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products, {bool isFavorite = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return _buildEmptyState(isFavorite);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index], isFavorite: isFavorite);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isFavorite) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFavorite ? Icons.favorite_border : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isFavorite ? 'Belum ada favorit' : 'Belum ada iklan',
            style: AppTheme.of(context).textStyle.titleMedium.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFavorite
                ? 'Iklan yang Anda sukai akan muncul di sini'
                : 'Iklan yang Anda pasang akan muncul di sini',
            textAlign: TextAlign.center,
            style: AppTheme.of(
              context,
            ).textStyle.bodyMedium.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, {bool isFavorite = false}) {
    final theme = AppTheme.of(context);

    if (isFavorite) {
      return InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/product-details', arguments: product);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardImage(product),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: theme.textStyle.bodyLarge.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.formattedPrice,
                        style: theme.textStyle.titleMedium.copyWith(
                          color: theme.colors.primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/product-details', arguments: product);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                color: theme.colors.grey.withAlpha(80),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'dari: ${DateFormat('dd MMM yyyy').format(product.createdAt)} - sampai: ${DateFormat('dd MMM yyyy').format(product.createdAt.add(const Duration(days: 30)))}',
                      style: theme.textStyle.bodyMedium.copyWith(
                        color: theme.colors.primary,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editProduct(context, product);
                            break;
                          case 'deactivate':
                            _deactivateProduct(context, product);
                            break;
                          case 'delete':
                            _deleteProduct(context, product);
                            break;
                        }
                      },
                      color: theme.colors.background,
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'deactivate',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility_off,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Nonaktifkan'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardImage(product),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: theme.textStyle.bodyLarge.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.formattedPrice,
                          style: theme.textStyle.titleMedium.copyWith(
                            color: theme.colors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStatusBadge(product.status),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildStatusText(
                            product.status,
                            product.createdAt
                                .add(const Duration(days: 30))
                                .difference(DateTime.now())
                                .inDays,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (product.status != ProductStatus.sold) ...[
                    const SizedBox(height: 16),
                    _buildActionButtons(product.status),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(Product product) {
    if (product.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          product.images.first,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildImagePlaceholder(),
        ),
      );
    }
    return _buildImagePlaceholder(isIcon: true);
  }

  Widget _buildImagePlaceholder({bool isIcon = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isIcon ? Colors.transparent : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child:
          isIcon
              ? const Icon(
                Icons.sell_outlined,
                color: Color(0xfff2c457),
                size: 40,
              )
              : const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 40,
              ),
    );
  }

  Widget _buildStatusBadge(ProductStatus status) {
    String text;
    Color borderColor;
    Color textColor;

    switch (status) {
      case ProductStatus.active:
        text = 'AKTIF';
        borderColor = const Color(0xffa1e0a1);
        textColor = const Color(0xff0b640b);
        break;
      case ProductStatus.sold:
        text = 'TERJUAL';
        borderColor = Colors.grey;
        textColor = Colors.black87;
        break;
      case ProductStatus.expired:
        text = 'KADALUWARSA';
        borderColor = Colors.grey;
        textColor = Colors.black87;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTheme.of(context).textStyle.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusText(ProductStatus status, int remainingDays) {
    final style = AppTheme.of(context).textStyle.bodySmall.copyWith(
      color: AppTheme.of(context).colors.secondaryTextColor,
    );

    switch (status) {
      case ProductStatus.active:
        return Text.rich(
          TextSpan(
            text: 'Iklan ini sedang ditayangkan\n',
            children: [
              TextSpan(
                text: 'SISA $remainingDays HARI',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          style: style,
          textAlign: TextAlign.right,
        );
      case ProductStatus.expired:
        return Text.rich(
          TextSpan(
            text:
                'Iklan ini telah kadaluwarsa. Jika Anda menjualnya, silakan Tandai sebagai ',
            children: [
              TextSpan(
                text: 'dijual',
                style: TextStyle(
                  color: AppTheme.of(context).colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          style: style,
          textAlign: TextAlign.right,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButtons(ProductStatus status) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colors.primary,
              side: BorderSide(color: theme.colors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Tandai sebagai terjual',
              style: theme.textStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (status == ProductStatus.active) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
              child: Text(
                'Jual Lebih Cepat',
                style: theme.textStyle.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _editProduct(BuildContext context, Product product) {
    final category = Category(
      id: product.categoryId,
      name: product.categoryName,
    );

    Navigator.pushNamed(
      context,
      AppRoutes.createProduct,
      arguments: {
        'isEdit': true,
        'product': product,
        'selectedCategory': category,
      },
    );
  }

  void _deactivateProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.of(context).colors.background,
            title: const Text('Nonaktifkan Iklan'),
            content: const Text(
              'Apakah Anda yakin ingin menonaktifkan iklan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final productProvider = context.read<ProductProvider>();

                  navigator.pop();

                  final success = await productProvider.deactivateProduct(
                    product.id,
                  );

                  if (mounted) {
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Iklan berhasil dinonaktifkan'),
                        ),
                      );
                      _loadData();
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menonaktifkan iklan'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).colors.primary,
                ),
                child: const Text(
                  'Nonaktifkan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.of(context).colors.background,
            title: const Text('Hapus Iklan'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus iklan ini? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final productProvider = context.read<ProductProvider>();

                  navigator.pop();

                  final success = await productProvider.deleteProduct(
                    product.id,
                  );

                  if (mounted) {
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Iklan berhasil dihapus')),
                      );
                      _loadData();
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Gagal menghapus iklan')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
