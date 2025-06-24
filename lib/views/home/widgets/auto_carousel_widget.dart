import 'package:flutter/material.dart';
import 'package:olx_clone/utils/const.dart';
import 'dart:async';

import 'package:olx_clone/utils/theme.dart';

class AutoCarouselWidget extends StatefulWidget {
  final List<String> bannerImages;
  final Duration autoSlideDuration;
  final double height;

  const AutoCarouselWidget({
    super.key,
    required this.bannerImages,
    this.autoSlideDuration = const Duration(seconds: 3),
    this.height = 180.0,
  });

  @override
  State<AutoCarouselWidget> createState() => _AutoCarouselWidgetState();
}

class _AutoCarouselWidgetState extends State<AutoCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(widget.autoSlideDuration, (timer) {
      if (!mounted) return;

      if (_currentPage < widget.bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            SizedBox(
              height: widget.height,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      _currentPage = index;
                    });
                  }
                },
                itemCount: widget.bannerImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.detailIklan,
                        arguments: {
                          'images': widget.bannerImages,
                          'initialIndex': index,
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            widget.bannerImages[index].startsWith('http')
                                ? Image.network(
                                  widget.bannerImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder(index);
                                  },
                                )
                                : Image.asset(
                                  widget.bannerImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder(index);
                                  },
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.bannerImages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  // width: _currentPage == index ? 20 : 6,
                  width: 30,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? AppTheme.of(context).colors.primary
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 50, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Banner ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
