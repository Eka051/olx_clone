import 'package:flutter/material.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/view/home/widgets/sliver_category_widget.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/home_provider.dart';
import 'package:olx_clone/view/home/widgets/home_app_bar.dart';
import 'package:olx_clone/view/home/widgets/location_widget.dart';
import 'package:olx_clone/view/home/widgets/search_bar_widget.dart';
import 'package:olx_clone/view/home/widgets/auto_carousel_widget.dart';
import 'package:olx_clone/view/home/widgets/product_grid_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    HomeAppBar(
                      onOfferTap: homeProvider.onOfferTapped,
                      onReceiptTap: homeProvider.onReceiptTapped,
                      locationWidget: LocationWidget(
                        location: homeProvider.selectedLocation,
                        onTap: homeProvider.onLocationTapped,
                      ),
                    ),
                    // Search Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SearchBarWidget(
                        onSearch: homeProvider.onSearch,
                        onNotificationTap: homeProvider.onNotificationTapped,
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
                              onPressed: () {},
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
                      child: Container(
                        height: 12,
                        color: Colors.grey[300],
                      ),
                    ),
                    // Product Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        child: Text(
                          'Rekomendasi baru',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppTheme.of(context).colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Product Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: ProductGridWidget(itemCount: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
