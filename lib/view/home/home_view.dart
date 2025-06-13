import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/home_provider.dart';
import 'package:olx_clone/view/home/widgets/home_app_bar.dart';
import 'package:olx_clone/view/home/widgets/location_widget.dart';
import 'package:olx_clone/view/home/widgets/search_bar_widget.dart';
import 'package:olx_clone/view/home/widgets/auto_carousel_widget.dart';
import 'package:olx_clone/view/home/widgets/home_content_list.dart';

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
                    // Content List
                    HomeContentList(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 100,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Item $index',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
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
