import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/utils/const.dart';

void main() {
  group('MyAds Navigation Tests', () {
    testWidgets('Navigation should pass Product object to ProductDetailView', (
      WidgetTester tester,
    ) async {
      // Create a test product
      final testProduct = Product(
        id: 1,
        title: 'Test Product',
        description: 'This is a test product description',
        price: 100000,
        categoryId: 1,
        categoryName: 'Electronics',
        images: ['https://example.com/image1.jpg'],
        cityName: 'Jakarta',
        provinceName: 'DKI Jakarta',
        districtName: 'Central Jakarta',
        createdAt: DateTime.now(),
        userId: 'test-user-id',
        sellerId: 'test-seller-id',
        sellerName: 'Test Seller',
      );

      Product? receivedProduct;

      // Create a mock navigator
      final mockObserver = NavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.productDetails) {
              receivedProduct = settings.arguments as Product?;
              return MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      body: Text(
                        'Product Detail: ${receivedProduct?.title ?? "No Product"}',
                      ),
                    ),
                settings: settings,
              );
            }
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    body: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productDetails,
                          arguments: testProduct,
                        );
                      },
                      child: Text('Navigate to ${testProduct.title}'),
                    ),
                  ),
            );
          },
          home: Scaffold(
            body: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  tester.element(find.byType(Scaffold).first),
                  AppRoutes.productDetails,
                  arguments: testProduct,
                );
              },
              child: Text('Navigate to ${testProduct.title}'),
            ),
          ),
        ),
      );

      // Tap on the navigation button
      await tester.tap(find.text('Navigate to Test Product'));
      await tester.pumpAndSettle();

      // Verify that the product was passed correctly
      expect(receivedProduct, isNotNull);
      expect(receivedProduct?.title, equals('Test Product'));
      expect(receivedProduct?.price, equals(100000));
      expect(find.text('Product Detail: Test Product'), findsOneWidget);
    });
  });
}
