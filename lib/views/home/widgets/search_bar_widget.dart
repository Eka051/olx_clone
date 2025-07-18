import 'package:flutter/material.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';

class SearchBarWidget extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onNotificationTap;
  final String hintText;

  SearchBarWidget({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onNotificationTap,
    this.hintText = 'Temukan Mobil, Handphone, dan lainnya',
  });

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.85),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: 8.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44.0,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.of(context).colors.primary,
                      size: 20,
                    ),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: onClear,
                            color: Colors.grey[600],
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusM),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusM),
                      borderSide: BorderSide(
                        color: AppTheme.of(context).colors.primary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusM),
                      borderSide: BorderSide(
                        color: AppTheme.of(context).colors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44.0,
              width: 44.0,
              child: IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(Icons.notifications_outlined, size: 28),
                color: AppTheme.of(context).colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is SearchBarWidget) {
      return controller != oldDelegate.controller ||
          controller.text != oldDelegate.controller.text;
    }
    return true;
  }
}