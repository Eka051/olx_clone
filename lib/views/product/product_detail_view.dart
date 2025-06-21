import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/services/chat_service.dart';
import 'package:olx_clone/views/chat/chat_room_view.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Product? product =
        ModalRoute.of(context)?.settings.arguments as Product?;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            SizedBox(
              height: 300,
              width: double.infinity,
              child:
                  product.images.isNotEmpty
                      ? PageView.builder(
                        itemCount: product.images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            product.images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    product.title,
                    style: AppTheme.of(context).textStyle.headlineMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),

                  // Product Price
                  Text(
                    product.formattedPrice,
                    style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                      color: AppTheme.of(context).colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Location and Date
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.location,
                          style: AppTheme.of(context).textStyle.bodyMedium
                              .copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      Text(
                        product.timePosted,
                        style: AppTheme.of(
                          context,
                        ).textStyle.bodySmall.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Category
                  if (product.categoryName.isNotEmpty) ...[
                    Text(
                      'Category',
                      style: AppTheme.of(context).textStyle.titleMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName,
                      style: AppTheme.of(context).textStyle.bodyMedium,
                    ),
                    const SizedBox(height: 16.0),
                  ], // Product Description
                  Text(
                    'Description',
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'No description available',
                    style: AppTheme.of(context).textStyle.bodyMedium,
                  ),
                  const SizedBox(height: 24.0),

                  // Product Details
                  Text(
                    'Product Details',
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildDetailRow('Product ID', product.id.toString()),
                  if (product.categoryName.isNotEmpty)
                    _buildDetailRow('Category', product.categoryName),
                  _buildDetailRow('Location', product.location),
                  _buildDetailRow('Posted', product.timePosted),
                  const SizedBox(height: 24.0),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          product.status == ProductStatus.active
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            product.status == ProductStatus.active
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    child: Text(
                      product.status == ProductStatus.active
                          ? 'Available'
                          : 'Sold',
                      style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                        color:
                            product.status == ProductStatus.active
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _startChat(context, product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.chat),
              label: const Text(
                'Chat Penjual',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, Product product) async {
    final authProvider = Provider.of<AuthProviderApp>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk mengirim pesan'),
        ),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      final chatRoomData = await ChatService.createChatRoom(
        product.id,
        'Halo, saya tertarik dengan produk ini.',
        authProvider.jwtToken!,
      );

      if (chatRoomData != null) {
        final chatRoom = ChatRoom(
          id: chatRoomData['id'] ?? 'temp_id',
          productId: product.id,
          productTitle: product.title,
          buyerId: authProvider.currentFirebaseUser?.uid ?? 'current_user',
          buyerName:
              authProvider.currentFirebaseUser?.displayName ?? 'Current User',
          sellerId: chatRoomData['sellerId'] ?? 'seller_${product.id}',
          sellerName: chatRoomData['sellerName'] ?? 'Penjual',
          createdAt: DateTime.now(),
          unreadCount: 0,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatRoomView(chatRoom: chatRoom, product: product),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat chat room')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
