import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:olx_clone/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final String _backendUrl = 'https://olx-api-production.up.railway.app';
  final List<Category> _categories = [];
  List<Category> get categories => _categories;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool _hasInitialized = false;
  bool get hasInitialized => _hasInitialized;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  List<Category> _filteredCategories = [];
  List<Category> get filteredCategories =>
      _filteredCategories.isEmpty && _searchQuery.isEmpty
          ? _categories
          : _filteredCategories;

  CategoryProvider() {
    getCategories();
  }
  Future<void> getCategories() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await fetchCategoriesFromBackend();
      _categories.clear();
      _categories.addAll(response);
      _hasInitialized = true;
      _filterCategories();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _hasInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Category>> fetchCategoriesFromBackend() async {
    final url = Uri.parse('$_backendUrl/api/categories');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> categoriesData = jsonResponse['data'] ?? [];
          return categoriesData.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception(
            'API Error: ${jsonResponse['message'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Service not found. Please try again later.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      rethrow;
    }
  }

  void clearCategories() {
    _categories.clear();
    _hasError = false;
    _errorMessage = '';
    _hasInitialized = false;
    clearSearch();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterCategories();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredCategories.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _filterCategories() {
    if (_searchQuery.isEmpty) {
      _filteredCategories.clear();
    } else {
      _filteredCategories =
          _categories
              .where(
                (category) =>
                    category.name.toLowerCase().contains(_searchQuery),
              )
              .toList();
    }
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  bool get isEmpty => _categories.isEmpty;

  bool get isEmptyButInitialized =>
      _categories.isEmpty && _hasInitialized && !_hasError;

  int get categoriesCount => _categories.length;

  Future<void> refreshCategories() async {
    clearCategories();
    await getCategories();
  }

  Future<void> initializeCategories() async {
    if (!_hasInitialized && !_isLoading) {
      await getCategories();
    }
  }

  String getCategoryImagePath(String categoryName) {
    final Map<String, String> categoryImageMap = {
      'Mobil': 'assets/icons/CAR.png',
      'Properti': 'assets/icons/PROPERTI.png',
      'Motor': 'assets/icons/MOTOR.png',
      'Jasa & Lowongan Kerja': 'assets/icons/LOKER.png',
      'Handphone & Gadget': 'assets/icons/GADGET.png',
      'Hobi & Olahraga': 'assets/icons/HOBI.png',
      'Rumah Tangga': 'assets/icons/RUMAH-TANGGA.png',
      'Keperluan Pribadi': 'assets/icons/PRIBADI.png',
      'Perlengkapan Bayi': 'assets/icons/BAYI.png',
      'Kantor & Industri': 'assets/icons/KANTOR.png',
      'Barang Gratis': 'assets/icons/GIFT-1.png',
    };

    return categoryImageMap[categoryName] ?? 'assets/icons/gift.png';
  }

  String getCategoryImageById(int id) {
    final category = getCategoryById(id);
    return category != null
        ? getCategoryImagePath(category.name)
        : 'assets/icons/gift.png';
  }

  bool shouldShowLoadingIndicator() {
    return isLoading && !hasInitialized;
  }

  bool shouldShowErrorView() {
    return hasError && categories.isEmpty;
  }

  bool shouldShowEmptySearchView() {
    return filteredCategories.isEmpty && searchQuery.isNotEmpty;
  }

  void handleSearchClear() {
    clearSearch();
    notifyListeners();
  }

  void retryInitialization() {
    initializeCategories();
  }
}
