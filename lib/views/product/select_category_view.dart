import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/views/product/create_product_view.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/category_provider.dart';
import 'package:olx_clone/models/category.dart';

class SelectCategoryView extends StatefulWidget {
  const SelectCategoryView({super.key});

  @override
  State<SelectCategoryView> createState() => _SelectCategoryViewState();
}

class _SelectCategoryViewState extends State<SelectCategoryView> {
  final TextEditingController _searchController = TextEditingController();
  CategoryProvider? _categoryProvider;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryProvider = context.read<CategoryProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_categoryProvider!.hasInitialized) {
        _categoryProvider!.initializeCategories();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _categoryProvider?.clearSearch();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted && _categoryProvider != null) {
      _categoryProvider!.setSearchQuery(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.of(context).colors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).colors.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(deviceHeight * 0.07),
          child: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            title: Text(
              'Mau jual apa hari ini?',
              style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w100,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: Colors.grey[300], height: 1.0),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.shouldShowLoadingIndicator()) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.of(context).colors.primary,
                  ),
                );
              }

              if (categoryProvider.shouldShowErrorView()) {
                return _buildErrorView(
                  context,
                  categoryProvider,
                  deviceWidth,
                  deviceHeight,
                );
              }

              return Column(
                children: [
                  Column(
                    children: [
                      Text(
                        'Pilih Kategori',
                        style: AppTheme.of(
                          context,
                        ).textStyle.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Pilih kategori sesuai barang yang Anda jual',
                        style: AppTheme.of(
                          context,
                        ).textStyle.bodySmall.copyWith(
                          color: AppTheme.of(context).colors.primaryTextColor,
                          fontSize: deviceWidth * 0.025,
                        ),
                      ),
                    ],
                  ),
                  _buildSearchBar(context, deviceWidth),
                  Expanded(
                    child:
                        categoryProvider.shouldShowEmptySearchView()
                            ? _buildEmptySearchView(
                              context,
                              deviceWidth,
                              deviceHeight,
                            )
                            : _buildCategoriesList(
                              context,
                              deviceWidth,
                              categoryProvider,
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double deviceWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: deviceWidth * 0.04,
        vertical: deviceWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                hintStyle: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                  color: AppTheme.of(context).colors.hintTextColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: deviceWidth * 0.04,
                  vertical: deviceWidth * 0.04,
                ),
              ),
              style: AppTheme.of(
                context,
              ).textStyle.bodyMedium.copyWith(fontSize: deviceWidth * 0.04),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.of(context).colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: deviceWidth * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    double deviceWidth,
    CategoryProvider categoryProvider,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(deviceWidth * 0.04),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.95,
        crossAxisSpacing: 4,
        mainAxisSpacing: 6,
      ),
      itemCount: categoryProvider.filteredCategories.length,
      itemBuilder: (context, index) {
        final category = categoryProvider.filteredCategories[index];
        return _buildCategoryItem(context, category, deviceWidth);
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Category category,
    double deviceWidth,
  ) {
    final categoryProvider = context.read<CategoryProvider>();
    final imagePath = categoryProvider.getCategoryImagePath(category.name);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateProductView(selectedCategory: category),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(deviceWidth * 0.02),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: deviceWidth * 0.18,
              height: deviceWidth * 0.18,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(deviceWidth * 0.015),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.category,
                      size: deviceWidth * 0.09,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: deviceWidth * 0.01),
            Text(
              category.name,
              style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.of(context).colors.primaryTextColor,
                fontSize: deviceWidth * 0.03,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchView(
    BuildContext context,
    double deviceWidth,
    double deviceHeight,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(deviceWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: deviceWidth * 0.2,
              color: Colors.grey[300],
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Kategori Tidak Ditemukan',
              style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                color: AppTheme.of(context).colors.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: deviceHeight * 0.015),
            Text(
              'Coba gunakan kata kunci yang berbeda',
              style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                color: AppTheme.of(context).colors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: deviceHeight * 0.03),
            TextButton(
              onPressed: () {
                if (!mounted) return;

                _searchController.clear();
                _categoryProvider?.handleSearchClear();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.of(
                  context,
                ).colors.primary.withValues(alpha: 0.1),
                padding: EdgeInsets.symmetric(
                  horizontal: deviceWidth * 0.06,
                  vertical: deviceHeight * 0.012,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Hapus Pencarian',
                style: AppTheme.of(context).textStyle.labelLarge.copyWith(
                  color: AppTheme.of(context).colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    CategoryProvider categoryProvider,
    double deviceWidth,
    double deviceHeight,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(deviceWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: deviceWidth * 0.2,
              color: Colors.grey[400],
            ),
            SizedBox(height: deviceHeight * 0.03),
            Text(
              'Gagal Memuat Kategori',
              style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                color: AppTheme.of(context).colors.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Terjadi kesalahan saat memuat daftar kategori',
              style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                color: AppTheme.of(context).colors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: deviceHeight * 0.04),
            ElevatedButton(
              onPressed: () {
                if (!mounted) return;

                categoryProvider.retryInitialization();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).colors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: deviceWidth * 0.08,
                  vertical: deviceHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: AppTheme.of(context).textStyle.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
