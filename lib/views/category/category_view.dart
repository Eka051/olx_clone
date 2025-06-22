import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/category_provider.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.of(context).colors.grey,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppTheme.of(context).colors.primary,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey[300], height: 1.0),
          ),
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, _) {
            if (!categoryProvider.hasInitialized &&
                !categoryProvider.isLoading &&
                !categoryProvider.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                categoryProvider.initializeCategories();
              });
            }

            if (categoryProvider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat kategori',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categoryProvider.errorMessage,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => categoryProvider.getCategories(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (categoryProvider.categories.isEmpty) {
              return const Center(
                child: Text(
                  'Memuat kategori...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => categoryProvider.refreshCategories(),
              child: ListView.separated(
                itemCount: categoryProvider.categoriesCount,
                separatorBuilder:
                    (context, index) =>
                        const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  final imagePath = categoryProvider.getCategoryImagePath(
                    category.name,
                  );

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Image.asset(
                      imagePath,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.category,
                          color: Colors.grey[400],
                          size: 40,
                        );
                      },
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/category-products',
                        arguments: {
                          'categoryId': category.id,
                          'categoryName': category.name,
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
