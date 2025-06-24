import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/cart_item.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/views/adPackage/cart_view.dart';
import 'package:olx_clone/views/payment/payment_webview.dart';

class CartProvider with ChangeNotifier {
  String? _token;
  final String _baseUrl = 'https://olx-api-production.up.railway.app/api';
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _cartTotalPrice = 0;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cartTotalPrice => _cartTotalPrice;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void updateAuth(AuthProviderApp auth) {
    _token = auth.jwtToken;
    if (_token != null) {
      fetchCart();
    } else {
      _cartItems = [];
      _cartTotalPrice = 0;
      notifyListeners();
    }
  }

  void _calculateTotals() {
    _cartTotalPrice = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    notifyListeners();
  }

  Future<void> fetchCart() async {
    if (_token == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> cartData = [];
        if (data['data'] is List) {
          cartData = data['data'];
        } else if (data['data'] is Map && data['data']['items'] is List) {
          cartData = data['data']['items'];
        } else if (data['data'] is Map && data['data']['cartItems'] is List) {
          cartData = data['data']['cartItems'];
        }
        _cartItems = cartData.map((item) => CartItem.fromJson(item)).toList();
        _calculateTotals();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? 'Gagal memuat keranjang.';
        _cartItems = [];
        _cartTotalPrice = 0;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat keranjang: ${e.toString()}';
      _cartItems = [];
      _cartTotalPrice = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    int? adPackageId,
    int? productId,
    int quantity = 1,
  }) async {
    if (_token == null) {
      _errorMessage = 'Silakan masuk untuk menambahkan ke keranjang.';
      notifyListeners();
      return;
    }
    if (adPackageId == null || productId == null) {
      _errorMessage = 'Product ID dan Ad Package ID harus disediakan.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'adPackageId': adPackageId,
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ?? 'Gagal menambahkan ke keranjang.';
      }
    } catch (e) {
      _errorMessage = 'Gagal menambahkan ke keranjang: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (_token == null) return;

    final originalItems = List<CartItem>.from(_cartItems);
    _cartItems.removeWhere((item) => item.id == cartItemId);
    _calculateTotals();
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/$cartItemId'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        _cartItems = originalItems;
        _calculateTotals();
        notifyListeners();
      }
    } catch (e) {
      _cartItems = originalItems;
      _calculateTotals();
      notifyListeners();
    }
  }

  Future<Map<String, String>?> _checkout() async {
    if (_token == null || _cartItems.isEmpty) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'cartItemIds': _cartItems.map((item) => item.id).toList(),
        }),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          _errorMessage = 'Gagal membuat pesanan: Response kosong dari server.';
        } else {
          final responseData = json.decode(response.body);
          if (responseData['data'] != null &&
              responseData['data']['redirectUrl'] != null &&
              responseData['data']['finishUrl'] != null) {
            final String redirectUrl = responseData['data']['redirectUrl'];
            final String finishUrl = responseData['data']['finishUrl'];
            return {'redirectUrl': redirectUrl, 'finishUrl': finishUrl};
          } else {
            _errorMessage =
                responseData['message'] ?? 'Respons checkout tidak valid.';
          }
        }
      } else {
        final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
        _errorMessage = errorData['message'] ?? 'Gagal membuat pesanan.';
      }
    } catch (e) {
      _errorMessage = 'Gagal membuat pesanan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> clearCart() async {
    if (_token == null || _cartItems.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    List<String> itemIds = _cartItems.map((item) => item.id).toList();

    try {
      for (String id in itemIds) {
        final response = await http.delete(
          Uri.parse('$_baseUrl/cart/$id'),
          headers: {'Authorization': 'Bearer $_token'},
        );
        if (response.statusCode != 200 && response.statusCode != 204) {
          _errorMessage = 'Gagal menghapus beberapa item.';
          break;
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mengosongkan keranjang.';
    } finally {
      await fetchCart();
    }
  }

  Future<void> processCheckout(BuildContext context) async {
    final int currentTotal = cartTotalPrice;
    final checkoutData = await _checkout();

    if (checkoutData != null && context.mounted) {
      final String? paymentUrl = checkoutData['redirectUrl'];
      final String? finishUrl = checkoutData['finishUrl'];

      if (paymentUrl == null || finishUrl == null) {
        _showErrorDialog(context, 'Data pembayaran tidak valid dari server.');
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PaymentWebview(paymentUrl: paymentUrl, finishUrl: finishUrl),
        ),
      );

      if (result == 'success' && context.mounted) {
        await clearCart();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => PaymentResultView(
                  isSuccess: true,
                  totalAmount: currentTotal,
                ),
          ),
        );
      } else if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => PaymentResultView(
                  isSuccess: false,
                  totalAmount: currentTotal,
                ),
          ),
        );
      }
    } else if (context.mounted) {
      _showErrorDialog(context, errorMessage ?? 'Gagal membuat pesanan');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;
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
}
