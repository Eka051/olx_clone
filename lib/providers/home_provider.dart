import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedLocation = 'Kec. Sumbersari, Kab. Jember';

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
}
