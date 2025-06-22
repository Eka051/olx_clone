import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/category_provider.dart';

class SliverCategoryWidget extends StatelessWidget {
  const SliverCategoryWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (!categoryProvider.hasInitialized && !categoryProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            categoryProvider.initializeCategories();
          });
        }

        if (categoryProvider.categories.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];
                final imagePath = categoryProvider.getCategoryImagePath(
                  category.name,
                );
                return _buildCategoryItem(
                  context,
                  imagePath,
                  category.name,
                  category.id,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String imagePath,
    String label,
    int categoryId,
  ) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final iconSize = deviceWidth * 0.13;
    final textSize = deviceWidth * 0.028;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/category-products',
          arguments: {'categoryId': categoryId, 'categoryName': label},
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.category,
                      size: iconSize * 0.6,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
