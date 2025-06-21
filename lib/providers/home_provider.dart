import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:olx_clone/services/google_geocoding_service.dart';

class HomeProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearching = false;
  final String _baseUrl = 'https://olx-api.azurewebsites.net';
  String _selectedLocation = 'Mendapatkan lokasi...';

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

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  void updateLocation(String location) {
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
    try {
      final url = Uri.parse('$_baseUrl/api/products');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
    }
  }

  HomeProvider() {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _selectedLocation = 'Layanan lokasi tidak aktif';
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

      final result = await GoogleGeocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (result != null) {
        _selectedLocation = '${result['district']}, ${result['city']}';
      } else {
        _selectedLocation = 'Lokasi tidak ditemukan';
      }
      notifyListeners();
    } catch (e) {
      _selectedLocation = 'Gagal mendapatkan lokasi';
      notifyListeners();
    }
  }
}
