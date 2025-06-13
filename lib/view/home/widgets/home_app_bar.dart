import 'package:flutter/material.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onOfferTap;
  final VoidCallback onReceiptTap;
  final Widget locationWidget;

  const HomeAppBar({
    super.key,
    required this.onOfferTap,
    required this.onReceiptTap,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: onOfferTap,
                            icon: Icon(
                              Icons.local_offer_outlined,
                              size: 22,
                              color: AppTheme.of(context).colors.primary,
                            ),
                            padding: const EdgeInsets.all(6),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: onReceiptTap,
                            icon: Icon(
                              Icons.newspaper_outlined,
                              size: 22,
                              color: AppTheme.of(context).colors.primary,
                            ),
                            padding: const EdgeInsets.all(6),
                            visualDensity: VisualDensity.compact,
                          ),
                          locationWidget,
                        ],
                      ),
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
