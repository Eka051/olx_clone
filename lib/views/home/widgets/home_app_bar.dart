import 'package:flutter/material.dart';
import 'package:olx_clone/utils/const.dart';

class HomeAppBar extends StatelessWidget {
  final Widget locationWidget;

  const HomeAppBar({
    super.key,
    required this.locationWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 60.0,
      floating: false,
      pinned: false,
      backgroundColor: Colors.white,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  child: Row(
                    children: [
                      Image.asset(AppAssets.olxBlueLogo, height: 50),
                      const Spacer(),
                      locationWidget,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
