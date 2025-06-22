import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/views/product/product_detail_view.dart';

void main() {
  group('Product Navigation Tests', () {
    testWidgets(
      'ProductDetailView should display product data when passed as argument',
      (WidgetTester tester) async {
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
          districtName: 'Jakarta Pusat',
          createdAt: DateTime.now(),
          userId: 'test-user-id',
          sellerId: 'test-seller-id',
          sellerName: 'Test Seller',
        );

        // Build the ProductDetailView with the test product as argument
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) => ProductDetailView()),
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                  builder: (context) => ProductDetailView(),
                  settings: RouteSettings(arguments: testProduct),
                );
              }
              return null;
            },
            initialRoute: '/',
          ),
        );

        // Wait for the widget to settle
        await tester.pumpAndSettle();

        // Verify that the product details are displayed
        expect(find.text('Test Product'), findsOneWidget);
        expect(find.text('Rp 100.000'), findsOneWidget);
        expect(find.text('This is a test product description'), findsOneWidget);
        expect(find.text('Electronics'), findsOneWidget);
        expect(
          find.text('Jakarta Pusat, Jakarta, DKI Jakarta'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ProductDetailView should show error when no product is passed',
      (WidgetTester tester) async {
        // Build the ProductDetailView without arguments
        await tester.pumpWidget(MaterialApp(home: ProductDetailView()));

        // Wait for the widget to settle
        await tester.pumpAndSettle();

        // Verify that the error message is displayed
        expect(find.text('Product not found'), findsOneWidget);
      },
    );
  });
}
