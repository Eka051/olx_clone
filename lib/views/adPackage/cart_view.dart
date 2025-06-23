import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/ad_provider.dart';
import 'package:olx_clone/views/payment/payment_webview.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: Color(0xFF002F34),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF002F34),
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      body:
          adProvider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF002F34)),
              )
              : adProvider.cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      itemCount: adProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = adProvider.cartItems[index];
                        return _buildCartItem(cartItem, adProvider);
                      },
                    ),
                  ),
                  _buildBottomSection(adProvider),
                ],
              ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Anda kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002F34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ayo, temukan paket iklan terbaik untuk Anda!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002F34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Lihat Paket Iklan'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, AdProvider adProvider) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    cartItem.adPackageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002F34),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rp ${_formatPrice(cartItem.totalPrice)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002F34),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed:
                          cartItem.quantity > 1
                              ? () => adProvider.updateCartItemQuantity(
                                cartItem.id,
                                cartItem.quantity - 1,
                              )
                              : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        cartItem.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002F34),
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed:
                          () => adProvider.updateCartItemQuantity(
                            cartItem.id,
                            cartItem.quantity + 1,
                          ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => adProvider.removeFromCart(cartItem.id),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.grey[200],
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? const Color(0xFF002F34) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(AdProvider adProvider) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF002F34),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rp ${_formatPrice(adProvider.cartTotalPrice)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002F34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_isProcessingPayment || adProvider.isLoading)
                      ? null
                      : () => _processCheckout(adProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002F34),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child:
                  (_isProcessingPayment || adProvider.isLoading)
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Lanjut ke Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(AdProvider adProvider) async {
    setState(() => _isProcessingPayment = true);

    try {
      final paymentUrl = await adProvider.createCheckout();

      if (paymentUrl != null && mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebview(
              paymentUrl: paymentUrl,
              finishUrl: 'https://your-finish-url.com/',
            ),
          ),
        );

        if (result == 'success') {
          adProvider.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran berhasil!'),
              backgroundColor: Color(0xFF00A49F),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (result == 'failed') {
          _showErrorDialog('Pembayaran gagal atau dibatalkan.');
        }
      } else if (mounted) {
        _showErrorDialog(adProvider.errorMessage ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terjadi Kesalahan'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF002F34)),
                ),
              ),
            ],
          ),
    );
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }
}
