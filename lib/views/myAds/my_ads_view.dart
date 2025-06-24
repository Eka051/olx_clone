import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/models/ad_package.dart';
import 'package:olx_clone/models/category.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/providers/ad_provider.dart';
import 'package:olx_clone/providers/product_provider.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';

class MyAdsView extends StatefulWidget {
  const MyAdsView({super.key});

  @override
  State<MyAdsView> createState() => _MyAdsViewState();
}

class _MyAdsViewState extends State<MyAdsView> with TickerProviderStateMixin {
  late final TabController _tabController;
  ProductProvider? _productProvider;

  List<Product> _userProducts = [];
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  bool _isListenerAdded = false;

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
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_isListenerAdded && _productProvider != null) {
      _productProvider!.removeListener(_onProductProviderChange);
    }
    super.dispose();
  }

  void _onProductProviderChange() {
    if (!mounted) return;

    if (_productProvider?.shouldRefreshMyAds ?? false) {
      _productProvider!.clearRefreshFlag();
      Future.microtask(() {
        if (mounted) _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final productProvider = context.read<ProductProvider>();
    final userProductsFuture = productProvider.getUserProducts(isMyAds: true);
    final favoriteProductsFuture = productProvider.getFavoriteProducts();

    final results = await Future.wait([userProductsFuture, favoriteProductsFuture]);

    if (mounted) {
      setState(() {
        _userProducts = results[0];
        _favoriteProducts = results[1];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context, innerBoxIsScrolled),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(_userProducts),
              _buildProductList(_favoriteProducts, isFavorite: true),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, bool innerBoxIsScrolled) {
    final theme = AppTheme.of(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return SliverAppBar(
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
      title: innerBoxIsScrolled
          ? Text(
              'Iklan Saya',
              style:
                  theme.textStyle.titleLarge.copyWith(color: Colors.black, fontSize: 16),
            )
          : null,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
        background: Container(
          color: theme.colors.surface,
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
                ),
              ),
              const Spacer(),
              Text(
                'Iklan Saya',
                style: theme.textStyle.titleLarge.copyWith(color: Colors.black),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.07),
        child: Container(
          color: theme.colors.surface,
          padding: EdgeInsets.symmetric(
            horizontal: deviceWidth * 0.04,
            vertical: deviceHeight * 0.01,
          ),
          child: Row(
            children: [
              _buildTabButton(context, 'IKLAN', 0),
              SizedBox(width: deviceWidth * 0.03),
              _buildTabButton(context, 'FAVORIT', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int index) {
    final theme = AppTheme.of(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            final isSelected = _tabController.index == index;
            return Container(
              padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.015),
              decoration: BoxDecoration(
                color: isSelected ? theme.colors.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  text,
                  style: theme.textStyle.titleSmall.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: deviceWidth * 0.035,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products, {bool isFavorite = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: Stack(
          children: [ListView(), _buildEmptyState(isFavorite)],
        ),
      );
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
    final theme = AppTheme.of(context);
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
            style: theme.textStyle.titleMedium.copyWith(
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
            style: theme.textStyle.bodyMedium.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, {bool isFavorite = false}) {
    return isFavorite
        ? _buildFavoriteCard(product)
        : _buildUserAdCard(product);
  }

  Widget _buildFavoriteCard(Product product) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/product-details', arguments: product),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
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
                    Text(product.title, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(
                      product.formattedPrice,
                      style: theme.textStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildUserAdCard(Product product) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/product-details', arguments: product),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardHeader(product),
            const Divider(height: 1, thickness: 1),
            _buildCardBody(product),
            const Divider(height: 1, thickness: 1),
            _buildCardFooter(product),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Product product) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        color: theme.colors.grey.withOpacity(0.2),
      ),
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dipasang: ${DateFormat('dd MMM yyyy').format(product.createdAt)}',
            style: theme.textStyle.bodyMedium.copyWith(color: theme.colors.primary),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(value, product),
            color: theme.colors.background,
            icon: const Icon(Icons.more_vert, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];
              if (product.isActive && product.status == ProductStatus.active) {
                items.add(const PopupMenuItem<String>(value: 'edit', child: Text('Edit')));
                items.add(const PopupMenuItem<String>(value: 'deactivate', child: Text('Nonaktifkan')));
              } else {
                items.add(const PopupMenuItem<String>(value: 'activate', child: Text('Aktifkan')));
              }
              items.add(const PopupMenuItem<String>(value: 'delete', child: Text('Hapus')));
              return items;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody(Product product) {
    final theme = AppTheme.of(context);
    return Padding(
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
                Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(
                  product.formattedPrice,
                  style: theme.textStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatusBadge(product),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildStatusText(product),
                ),
              ),
            ],
          ),
          if (product.isActive && product.status != ProductStatus.sold) ...[
            const SizedBox(height: 16),
            _buildActionButtons(product),
          ],
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, Product product) {
    switch (value) {
      case 'edit':
        _editProduct(context, product);
        break;
      case 'deactivate':
        _deactivateProduct(context, product);
        break;
      case 'activate':
        _activateProduct(context, product);
        break;
      case 'delete':
        _deleteProduct(context, product);
        break;
    }
  }

  Widget _buildCardImage(Product product) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(isIcon: true),
    );
  }

  Widget _buildImagePlaceholder({bool isIcon = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isIcon ? Colors.transparent : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        isIcon ? Icons.sell_outlined : Icons.image_not_supported_outlined,
        color: isIcon ? const Color(0xfff2c457) : Colors.grey,
        size: 40,
      ),
    );
  }

  Widget _buildStatusBadge(Product product) {
    String text;
    Color borderColor;
    Color textColor;

    if (!product.isActive) {
      text = 'NONAKTIF';
      borderColor = Colors.grey;
      textColor = Colors.black87;
    } else {
      switch (product.status) {
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
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTheme.of(context)
            .textStyle
            .bodySmall
            .copyWith(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusText(Product product) {
    final theme = AppTheme.of(context);
    final style = theme.textStyle.bodySmall.copyWith(
      color: theme.colors.secondaryTextColor,
    );

    if (!product.isActive) {
      return Text('Iklan ini tidak aktif', style: style, textAlign: TextAlign.right);
    }

    final remainingDays =
        product.createdAt.add(const Duration(days: 30)).difference(DateTime.now()).inDays;

    if (product.status == ProductStatus.active) {
      return Text.rich(
        TextSpan(
          text: 'Iklan sedang ditayangkan\n',
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
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(Product product) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleMarkAsSold(product),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colors.primary,
              side: BorderSide(color: theme.colors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Tandai sebagai terjual',
              style: theme.textStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (product.status == ProductStatus.active) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAdPackageSelection(context, product),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
              child: Text(
                'Jual Lebih Cepat',
                style: theme.textStyle.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Future<void> _handleGenericAction(
      Future<bool> Function() action, String successMessage) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await action();
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      _loadData();
    } else {
      messenger.showSnackBar(
        SnackBar(
            content: Text(
                'Gagal: ${context.read<ProductProvider>()}')),
      );
    }
  }

  void _editProduct(BuildContext context, Product product) {
    final category = Category(id: product.categoryId, name: product.categoryName);
    Navigator.pushNamed(
      context,
      AppRoutes.createProduct,
      arguments: {'isEdit': true, 'product': product, 'selectedCategory': category},
    );
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmButtonColor,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.of(context).colors.background,
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmButtonColor),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _activateProduct(BuildContext context, Product product) {
    _showConfirmationDialog(
      title: 'Aktifkan Iklan',
      content: 'Apakah Anda yakin ingin mengaktifkan iklan ini?',
      confirmText: 'Aktifkan',
      confirmButtonColor: AppTheme.of(context).colors.primary,
      onConfirm: () => _handleGenericAction(
        () => context.read<ProductProvider>().activateProduct(product.id),
        'Iklan berhasil diaktifkan',
      ),
    );
  }

  void _deactivateProduct(BuildContext context, Product product) {
    _showConfirmationDialog(
      title: 'Nonaktifkan Iklan',
      content: 'Apakah Anda yakin ingin menonaktifkan iklan ini?',
      confirmText: 'Nonaktifkan',
      confirmButtonColor: AppTheme.of(context).colors.primary,
      onConfirm: () => _handleGenericAction(
        () => context.read<ProductProvider>().deactivateProduct(product.id),
        'Iklan berhasil dinonaktifkan',
      ),
    );
  }

  void _deleteProduct(BuildContext context, Product product) {
    _showConfirmationDialog(
      title: 'Hapus Iklan',
      content:
          'Apakah Anda yakin ingin menghapus iklan ini? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      confirmButtonColor: Colors.red,
      onConfirm: () => _handleGenericAction(
        () => context.read<ProductProvider>().deleteProduct(product.id),
        'Iklan berhasil dihapus',
      ),
    );
  }

  void _handleMarkAsSold(Product product) {
    _showConfirmationDialog(
      title: 'Tandai sebagai Terjual',
      content:
          'Apakah Anda yakin? Anda tidak dapat mengaktifkan kembali iklan setelah ditandai terjual.',
      confirmText: 'Ya, Tandai Terjual',
      confirmButtonColor: AppTheme.of(context).colors.primary,
      onConfirm: () => _handleGenericAction(
        () => context.read<ProductProvider>().soldProduct(product.id),
        'Iklan berhasil ditandai terjual',
      ),
    );
  }

  Future<void> _showAdPackageSelection(BuildContext context, Product product) async {
    final adProvider = context.read<AdProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    await adProvider.fetchAdPackages();
    if (!mounted) return;

    final selectedPackage = await showDialog<AdPackage>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pilih Paket Iklan'),
        content: Consumer<AdProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()));
            }
            if (provider.packages.isEmpty) {
              return const Text('Tidak ada paket iklan tersedia.');
            }
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.packages.length,
                itemBuilder: (context, index) {
                  final package = provider.packages[index];
                  return ListTile(
                    title: Text(package.name),
                    subtitle: Text(NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                        .format(package.price)),
                    onTap: () => Navigator.of(dialogContext).pop(package),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedPackage != null && mounted) {
      await adProvider.addToCart(selectedPackage, product.id);
      if (!mounted) return;
      if (adProvider.errorMessage == null) {
        navigator.pushNamed('/cart');
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(adProvider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}