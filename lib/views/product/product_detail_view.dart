import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/providers/product_provider.dart';
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
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final authProvider = Provider.of<AuthProviderApp>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final currentUserId = profileProvider.user?.id;
    final isSeller =
        authProvider.isLoggedIn &&
        currentUserId != null &&
        (currentUserId == product.sellerId || currentUserId == product.userId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          Selector<ProductProvider, bool>(
            selector:
                (context, provider) =>
                    provider.favoriteProductIds.contains(product.id),
            builder: (context, isFavorite, child) {
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                color: isFavorite ? Colors.red : null,
                onPressed: () {
                  context.read<ProductProvider>().toggleFavoriteStatus(
                    product.id,
                  );
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

                  Text(
                    product.formattedPrice,
                    style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                      color: AppTheme.of(context).colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16.0),

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

                  const Divider(color: Colors.grey, thickness: 1.0),
                  const SizedBox(height: 8.0),

                  Text(
                    'Penjual: ${product.sellerName}',
                    style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  const Divider(color: Colors.grey, thickness: 1.0),
                  const SizedBox(height: 16.0),

                  Text(
                    'ID IKLAN: ${product.id}',
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Divider(color: Colors.grey, thickness: 1.0),

                  Text(
                    'Deskripsi',
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Tidak ada deskripsi',
                    style: AppTheme.of(context).textStyle.bodyMedium,
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          isSeller
              ? null
              : Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'Chat Penjual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  void _startChat(BuildContext context, Product product) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) =>
              const Center(child: CircularProgressIndicator()),
    );

    final authProvider = Provider.of<AuthProviderApp>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (!authProvider.isLoggedIn || authProvider.currentFirebaseUser == null) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Silakan login untuk memulai chat.')),
      );
      navigator.pushNamed('/login');
      return;
    }

    try {
      // Create or get existing chat room
      final chatRoom = await ChatService.createChatRoom(
        productId: product.id.toString(),
        sellerId: product.sellerId,
        authToken: authProvider.jwtToken!,
      );

      navigator.pop();

      if (chatRoom != null) {
        // Send initial message if this is a new chat
        final initialMessage =
            'Halo, saya tertarik dengan iklan "${product.title}". Apakah masih tersedia?';
        await ChatService.sendMessage(
          chatRoom.id,
          initialMessage,
          authProvider.jwtToken!,
        );

        // Navigate to chat room
        navigator.push(
          MaterialPageRoute(
            builder:
                (context) => ChatRoomView(chatRoom: chatRoom, product: product),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Gagal memulai chat. Coba lagi.')),
        );
      }
    } catch (e) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }
}
