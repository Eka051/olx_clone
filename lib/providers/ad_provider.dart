import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/ad_package.dart';
import 'package:olx_clone/models/cart_item.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/providers/auth_provider.dart';

class AdProvider with ChangeNotifier {
  String? _token;
  final String _baseUrl = 'https://olx-api-production.up.railway.app/api';

  List<AdPackage> _packages = [];
  List<CartItem> _cartItems = [];
  List<Product> _myProducts = [];

  bool _isLoading = false;
  bool _isLoadingMyProducts = false;
  String? _errorMessage;
  int _cartTotalPrice = 0;

  List<AdPackage> get packages => _packages;
  List<CartItem> get cartItems => _cartItems;
  List<Product> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingMyProducts => _isLoadingMyProducts;
  String? get errorMessage => _errorMessage;
  int get cartTotalPrice => _cartTotalPrice;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void updateAuth(AuthProviderApp auth) {
    _token = auth.jwtToken;
    if (_token != null) {
      fetchAdPackages();
      fetchMyProducts();
      fetchCart();
    } else {
      _clearState();
    }
  }

  void _clearState() {
    _packages = [];
    _cartItems = [];
    _myProducts = [];
    _cartTotalPrice = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void _calculateTotals() {
    _cartTotalPrice = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    notifyListeners();
  }

  Future<void> _handleApiResponse(
    http.Response response,
    Function(Map<String, dynamic>) onSuccess,
  ) async {
    _errorMessage = null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        onSuccess(data);
      } else {
        _errorMessage = data['message'] ?? 'Terjadi kesalahan pada server.';
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? 'Gagal memproses permintaan.';
      } catch (e) {
        _errorMessage =
            'Gagal memproses permintaan. Status: ${response.statusCode}';
      }
    }
  }

  Future<void> fetchAdPackages() async {
    if (_token == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/adPackage'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      await _handleApiResponse(response, (data) {
        if(data['data'] != null) {
          _packages = (data['data'] as List).map((p) => AdPackage.fromJson(p)).toList();
        } else {
          _packages = [];
        }
      });
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server. Periksa koneksi Anda.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyProducts() async {
    if (_token == null) return;
    _isLoadingMyProducts = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products?isMyAds=true'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      await _handleApiResponse(response, (data) {
        if (data['data'] != null) {
        _myProducts =
            (data['data'] as List).map((p) => Product.fromJson(p)).toList();
        } else {
          _myProducts = [];
        }
      });
    } catch (e) {
      _errorMessage = 'Gagal memuat iklan saya.';
    } finally {
      _isLoadingMyProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchCart() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      await _handleApiResponse(response, (data) {
        if (data['data'] != null) {
          _cartItems = (data['data'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
          _calculateTotals();
        } else {
          _cartItems = [];
          _calculateTotals();
        }
      });
    } catch (e) {
      _errorMessage = 'Gagal memuat keranjang.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(AdPackage package, int productId) async {
    if (_token == null) return;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'adPackageId': package.id, 'productId': productId}),
      );
      await _handleApiResponse(response, (data) async {
        await fetchCart();
      });
    } catch (e) {
      _errorMessage = 'Gagal menambahkan ke keranjang.';
    }
    notifyListeners();
  }

  Future<void> removeFromCart(int cartItemId) async {
    if (_token == null) return;
    _cartItems.removeWhere((item) => item.id == cartItemId);
    _calculateTotals();
    notifyListeners();

    try {
      await http.delete(
        Uri.parse('$_baseUrl/cart/$cartItemId'),
        headers: {'Authorization': 'Bearer $_token'},
      );
    } catch (e) {
      fetchCart();
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    if (_token == null) return;
    final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (itemIndex == -1 || quantity <= 0) return;

    final oldItem = _cartItems[itemIndex];
    final unitPrice = (oldItem.totalPrice / oldItem.quantity).round();
    _cartItems[itemIndex] = oldItem.copyWith(
      quantity: quantity,
      totalPrice: unitPrice * quantity,
    );
    _calculateTotals();
    notifyListeners();

    try {
      await http.put(
        Uri.parse('$_baseUrl/cart/$cartItemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'quantity': quantity}),
      );
      await fetchCart();
    } catch (e) {
      await fetchCart();
    }
  }

  Future<Map<String, String>?> createCheckout() async {
    if (_token == null || _cartItems.isEmpty) {
      _errorMessage = 'Keranjang kosong atau Anda belum login.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/cart/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final String paymentUrl = responseData['data']['paymentUrl'];
          final String finishUrl = responseData['data']['finishUrl'];
          return {'paymentUrl': paymentUrl, 'finishUrl': finishUrl};
        } else {
          _errorMessage = responseData['message'] ?? 'Respons checkout tidak valid.';
        }
      } else {
        final errorData = json.decode(response.body);
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
    if (_token == null) return;
    _cartItems.clear();
    _calculateTotals();
    notifyListeners();
    try {
      await http.delete(
        Uri.parse('$_baseUrl/cart/clear'),
        headers: {'Authorization': 'Bearer $_token'},
      );
    } catch (e) {}
  }

  Future<String?> checkPaymentStatus(String invoiceNumber) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment/status/$invoiceNumber'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      String? status;
      await _handleApiResponse(response, (data) {
        status = data['data']['status'];
      });
      return status;
    } catch (e) {
      return 'ERROR';
    }
  }
}
