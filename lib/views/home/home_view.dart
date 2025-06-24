import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/views/home/widgets/sliver_category_widget.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/home_provider.dart';
import 'package:olx_clone/views/home/widgets/home_app_bar.dart';
import 'package:olx_clone/views/home/widgets/location_widget.dart';
import 'package:olx_clone/views/home/widgets/search_bar_widget.dart';
import 'package:olx_clone/views/home/widgets/auto_carousel_widget.dart';
import 'package:olx_clone/views/search_result_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: AppTheme.of(context).colors.primary,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    );
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    HomeAppBar(
                      locationWidget: LocationWidget(
                        location: homeProvider.selectedLocation,
                        onTap: () {},
                      ),
                    ),
                    // Search Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SearchBarWidget(
                        controller: homeProvider.searchController,
                        onChanged: homeProvider.onSearchQueryChanged,
                        onSubmitted: (_) {
                          if (homeProvider.searchController.text
                              .trim()
                              .isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SearchResultView(
                                      products:
                                          homeProvider.products
                                              .where(
                                                (p) => p.title
                                                    .toLowerCase()
                                                    .contains(
                                                      homeProvider
                                                          .searchController
                                                          .text
                                                          .trim()
                                                          .toLowerCase(),
                                                    ),
                                              )
                                              .toList(),
                                      query: homeProvider.searchController.text,
                                      isLoading: homeProvider.isLoading,
                                      error: homeProvider.error,
                                    ),
                              ),
                            );
                          }
                        },
                        onClear: () => homeProvider.clearSearch(context),
                        onNotificationTap:
                            () => homeProvider.onNotificationTapped(context),
                      ),
                    ),
                    // Banner Carousel
                    AutoCarouselWidget(
                      bannerImages: homeProvider.bannerImages,
                      height: 220,
                      autoSlideDuration: const Duration(seconds: 5),
                    ),
                    // Categories List
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Telusuri Kategori',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: AppTheme.of(context).colors.primary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/categories');
                              },
                              child: Text(
                                'Lihat Semua',
                                style: AppTheme.of(
                                  context,
                                ).textStyle.titleMedium.copyWith(
                                  color: AppTheme.of(context).colors.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      AppTheme.of(context).colors.primary,
                                  decorationThickness: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverCategoryWidget(),
                    SliverToBoxAdapter(
                      child: Container(height: 12, color: Colors.grey[300]),
                    ),
                    // Product Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        child: Text(
                          homeProvider.searchController.text.isEmpty
                              ? 'Rekomendasi baru'
                              : 'Hasil pencarian',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppTheme.of(context).colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (homeProvider.isLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (homeProvider.error != null)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  homeProvider.error!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (homeProvider.products.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada produk ditemukan',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = homeProvider.products[index];
                            return Builder(
                              builder: (context) {
                                // Copy the card from ProductGridWidget for consistency
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/product-details',
                                      arguments: product,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          offset: const Offset(0, 2),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              left: 8,
                                              right: 8,
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child:
                                                        product
                                                                .images
                                                                .isNotEmpty
                                                            ? Image.network(
                                                              product
                                                                  .images
                                                                  .first,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  color:
                                                                      Colors
                                                                          .grey[200],
                                                                  child: Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    color:
                                                                        Colors
                                                                            .grey[400],
                                                                    size: 40,
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                            : Container(
                                                              color:
                                                                  Colors
                                                                      .grey[200],
                                                              child: Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                                size: 40,
                                                              ),
                                                            ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.title,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  product.formattedPrice,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppTheme.of(
                                                          context,
                                                        ).colors.primary,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '${product.districtName}, ${product.cityName}',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      product.timePosted,
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }, childCount: homeProvider.products.length),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
