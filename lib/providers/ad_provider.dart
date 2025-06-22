import 'package:flutter/material.dart';
import 'package:olx_clone/models/ad_package.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartItem {
  final String id;
  final int adPackageId;
  final String adPackageName;
  final int quantity;
  final int? productId;
  final String? productTitle;
  final String userId;
  final String userName;
  final int price;

  CartItem({
    required this.id,
    required this.adPackageId,
    required this.adPackageName,
    required this.quantity,
    this.productId,
    this.productTitle,
    required this.userId,
    required this.userName,
    required this.price,
  });

  int get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      adPackageId: json['adPackageId'] ?? 0,
      adPackageName: json['adPackageName'] ?? '',
      quantity: json['quantity'] ?? 0,
      productId: json['productId'],
      productTitle: json['productTitle'],
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}

class AdProvider extends ChangeNotifier {
  final AuthProviderApp _authProvider;
  final String _apiBaseUrl = 'https://olx-api-production.up.railway.app/api';

  List<AdPackage> _packages = [];
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedFilterIndex = 0;

  AdProvider(this._authProvider) {
    if (_authProvider.isLoggedIn) {
      fetchCart();
    }
  }

  List<AdPackage> get packages => _packages;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedFilterIndex => _selectedFilterIndex;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }  Future<void> fetchAdPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Fetching ad packages from: $_apiBaseUrl/adPackage');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_authProvider.isLoggedIn && _authProvider.jwtToken != null) {
        headers['Authorization'] = 'Bearer ${_authProvider.jwtToken}';
        print('Using Authorization header with token');
      } else {
        print('No token available - fetching without auth');
      }
      
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/adPackage'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          if (data['data'] is List) {
            final List<dynamic> packagesJson = data['data'];
            _packages = packagesJson.map((json) => AdPackage.fromJson(json)).toList();
            print('Successfully loaded ${_packages.length} ad packages');
          } else {
            _errorMessage = 'Format data tidak sesuai - data bukan array';
          }
        } else {
          _errorMessage = data['message'] ?? 'Gagal memuat data paket iklan';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Sesi login telah berakhir. Silakan login kembali.';
        print('Authentication failed - token may be expired');
      } else {
        _errorMessage = 'Gagal memuat data paket iklan. Status: ${response.statusCode}';
      }
    } catch (e) {
      print('Error fetching ad packages: $e');
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCart() async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> cartJson = data['data'];
          _cartItems = cartJson.map((json) => CartItem.fromJson(json)).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      // Silent fail for cart fetch
    }
  }

  Future<void> addToCart(AdPackage package, {int? productId}) async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      _errorMessage = 'Silakan login terlebih dahulu';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final requestBody = {
        'adPackageId': package.id,
        'quantity': 1,
        if (productId != null) 'productId': productId,
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart();
      } else {
        _errorMessage = 'Gagal menambahkan ke keranjang';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/cart/$cartItemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchCart();
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      final cartItem = _cartItems.firstWhere((item) => item.id == cartItemId);

      await removeFromCart(cartItemId);

      final requestBody = {
        'adPackageId': cartItem.adPackageId,
        'quantity': quantity,
        if (cartItem.productId != null) 'productId': cartItem.productId,
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart();
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      _cartItems.clear();
      notifyListeners();
      return;
    }

    try {
      for (final item in _cartItems) {
        await http.delete(
          Uri.parse('$_apiBaseUrl/cart/${item.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_authProvider.jwtToken}',
          },
        );
      }
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      _cartItems.clear();
      notifyListeners();
    }
  }

  Future<String?> createCheckout() async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      _errorMessage = 'Silakan login terlebih dahulu';
      notifyListeners();
      return null;
    }

    if (_cartItems.isEmpty) {
      _errorMessage = 'Keranjang kosong';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/payments/cart/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          clearCart();
          return responseData['data']['invoiceNumber'];
        } else {
          _errorMessage = responseData['message'] ?? 'Gagal membuat checkout';
          return null;
        }
      } else {
        _errorMessage = 'Gagal membuat checkout. Kode: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> checkPaymentStatus(String invoiceNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/payments/$invoiceNumber'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['status'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPaymentStatus(String invoiceNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/payments/$invoiceNumber'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _packages.clear();
    _cartItems.clear();
    _selectedFilterIndex = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
