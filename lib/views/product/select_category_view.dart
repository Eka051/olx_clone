import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/category_provider.dart';
import 'package:olx_clone/models/category.dart';
import 'package:olx_clone/views/product/create_product_view.dart';

class SelectCategoryView extends StatefulWidget {
  const SelectCategoryView({super.key});

  @override
  State<SelectCategoryView> createState() => _SelectCategoryViewState();
}

class _SelectCategoryViewState extends State<SelectCategoryView> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (!categoryProvider.hasInitialized) {
        categoryProvider.initializeCategories();
      }
      _filteredCategories = categoryProvider.categories;
    });

    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    final categoryProvider = context.read<CategoryProvider>();

    setState(() {
      if (query.isEmpty) {
        _filteredCategories = categoryProvider.categories;
      } else {
        _filteredCategories =
            categoryProvider.categories
                .where(
                  (category) => category.name.toLowerCase().contains(query),
                )
                .toList();
      }
    });
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
            backgroundColor: AppTheme.of(context).colors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            title: Text(
              'Pilih Kategori',
              style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            if (categoryProvider.isLoading &&
                !categoryProvider.hasInitialized) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.of(context).colors.primary,
                ),
              );
            }

            if (categoryProvider.hasError &&
                categoryProvider.categories.isEmpty) {
              return _buildErrorView(
                context,
                categoryProvider,
                deviceWidth,
                deviceHeight,
              );
            }

            return Column(
              children: [
                // Search Bar
                _buildSearchBar(context, deviceWidth),

                // Categories List
                Expanded(
                  child:
                      _filteredCategories.isEmpty
                          ? _buildEmptySearchView(
                            context,
                            deviceWidth,
                            deviceHeight,
                          )
                          : _buildCategoriesList(context, deviceWidth),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double deviceWidth) {
    return Container(
      margin: EdgeInsets.all(deviceWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari kategori...',
          hintStyle: AppTheme.of(context).textStyle.bodyMedium.copyWith(
            color: AppTheme.of(context).colors.hintTextColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.of(context).colors.secondaryTextColor,
            size: deviceWidth * 0.06,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: AppTheme.of(context).colors.secondaryTextColor,
                      size: deviceWidth * 0.05,
                    ),
                  )
                  : null,
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
    );
  }

  Widget _buildCategoriesList(BuildContext context, double deviceWidth) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.04),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
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

    return Container(
      margin: EdgeInsets.only(bottom: deviceWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateProductView(selectedCategory: category),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(deviceWidth * 0.04),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: deviceWidth * 0.12,
                  height: deviceWidth * 0.12,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(deviceWidth * 0.025),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.category,
                          size: deviceWidth * 0.06,
                          color: AppTheme.of(context).colors.primary,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: deviceWidth * 0.04),

                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTheme.of(
                          context,
                        ).textStyle.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.of(context).colors.primaryTextColor,
                          fontSize: deviceWidth * 0.042,
                        ),
                      ),
                      if (category.name.length > 20) ...[
                        SizedBox(height: deviceWidth * 0.01),
                        Text(
                          'Kategori produk',
                          style: AppTheme.of(
                            context,
                          ).textStyle.bodyMedium.copyWith(
                            color:
                                AppTheme.of(context).colors.secondaryTextColor,
                            fontSize: deviceWidth * 0.035,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: deviceWidth * 0.045,
                  color: AppTheme.of(context).colors.secondaryTextColor,
                ),
              ],
            ),
          ),
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
                _searchController.clear();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.of(
                  context,
                ).colors.primary.withOpacity(0.1),
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
                categoryProvider.initializeCategories();
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
