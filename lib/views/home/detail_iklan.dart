import 'package:flutter/material.dart';

class DetailIklan extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const DetailIklan({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<DetailIklan> createState() => _DetailIklanState();
}

class _DetailIklanState extends State<DetailIklan> {
  late final PageController controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Carousel')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (i) {
                setState(() {
                  currentIndex = i;
                });
              },
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return image.startsWith('http')
                    ? Image.network(image, fit: BoxFit.contain)
                    : Image.asset(image, fit: BoxFit.contain);
              },
            ),
          ),
          if (widget.images.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          currentIndex == index
                              ? Colors.blue
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
