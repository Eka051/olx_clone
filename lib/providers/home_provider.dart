import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/services/google_geocoding_service.dart';
import 'package:olx_clone/utils/const.dart';

class HomeProvider extends ChangeNotifier {
  final String _baseUrl = 'https://olx-api-production.up.railway.app';

  List<Product> _products = [];
  String _selectedLocation = 'Mendapatkan lokasi...';
  String _city = '';
  String? _error;
  bool _isLoading = false;
  bool _disposed = false;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  List<Product> get products => _products;
  String get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<String> _bannerImages = [
    'assets/images/KV-SUPER-DEALS.png',
    'assets/images/PREMIUM-OLX.jpg',
    'assets/images/image-ads.jpg',
    'assets/images/booking.jpg',
  ];
  List<String> get bannerImages => _bannerImages;

  HomeProvider() {
    _initialize();
  }

  void _initialize() async {
    await _getCurrentLocation();
    fetchProducts();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      fetchProducts();
    });
    notifyListeners();
  }

  void searchNow() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    fetchProducts();
  }

  void clearSearch(BuildContext context) {
    searchController.clear();
    fetchProducts();
    FocusScope.of(context).unfocus();
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    if (_disposed) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final String searchTerm = searchController.text;
      Uri url;

      if (searchTerm.isEmpty) {
        url = Uri.parse('$_baseUrl/api/products');
      } else {
        final queryParams = {'searchTerm': searchTerm, 'city': _city};
        url = Uri.parse(
          '$_baseUrl/api/products/search',
        ).replace(queryParameters: queryParams);
      }

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              return http.Response(
                '{"success":true,"message":"Timeout","data":[]}',
                200,
              );
            },
          );

      if (_disposed) return;

      if (response.statusCode == 200) {
        final productResponse = productListResponseFromJson(response.body);
        if (productResponse.success) {
          _products = productResponse.data;
        } else {
          _error = productResponse.message;
        }
      } else {
        final responseData = json.decode(response.body);
        _error =
            responseData['message'] ??
            'Gagal memuat produk: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _selectedLocation = 'Layanan lokasi mati';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _selectedLocation = 'Izin lokasi ditolak';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _selectedLocation = 'Izin lokasi ditolak permanen';
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (_disposed) return;

      final result = await GoogleGeocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (_disposed) return;

      if (result != null && result['city'] != null) {
        _city = result['city']!;
        _selectedLocation = '${result['district']}, ${result['city']}';
      } else {
        _selectedLocation = 'Lokasi tidak ditemukan';
      }
    } catch (e) {
      _selectedLocation = 'Gagal mendapatkan lokasi';
    } finally {
      notifyListeners();
    }
  }

  void onNotificationTapped(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.notification);
  }
}
