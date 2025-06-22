import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:olx_clone/services/google_geocoding_service.dart';

class HomeProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearching = false;
  final String _baseUrl = 'https://olx-api-production.up.railway.app';
  String _selectedLocation = 'Mendapatkan lokasi...';
  bool _disposed = false;

  final List<String> _bannerImages = [
    'assets/images/KV-SUPER-DEALS.png',
    'assets/images/PREMIUM-OLX.jpg',
    'assets/images/image-ads.jpg',
    'assets/images/booking.jpg',
  ];

  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  String get selectedLocation => _selectedLocation;
  List<String> get bannerImages => _bannerImages;
  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    if (_disposed) return;
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch() {
    if (_disposed) return;
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void clearSearch() {
    if (_disposed) return;
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  void updateLocation(String location) {
    if (_disposed) return;
    _selectedLocation = location;
    notifyListeners();
  }

  void onOfferTapped() {}

  void onReceiptTapped() {}

  void onLocationTapped() {}

  void onNotificationTapped() {}

  void onSearch(String query) {
    updateSearchQuery(query);
  }

  Future<void> getAllProduct() async {
    if (_disposed) return;

    try {
      final url = Uri.parse('$_baseUrl/api/products');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (_disposed) return;

      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {}
  }

  HomeProvider() {
    _getCurrentLocation();
  }
  Future<void> _getCurrentLocation() async {
    if (_disposed) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!_disposed) {
          _selectedLocation = 'Layanan lokasi tidak aktif';
          notifyListeners();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!_disposed) {
            _selectedLocation = 'Izin lokasi ditolak';
            notifyListeners();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!_disposed) {
          _selectedLocation = 'Izin lokasi ditolak permanen';
          notifyListeners();
        }
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

      if (result != null) {
        _selectedLocation = '${result['district']}, ${result['city']}';
      } else {
        _selectedLocation = 'Lokasi tidak ditemukan';
      }
      notifyListeners();
    } catch (e) {
      if (!_disposed) {
        _selectedLocation = 'Gagal mendapatkan lokasi';
        notifyListeners();
      }
    }
  }
}
