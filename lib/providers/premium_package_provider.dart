import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/premium_package.dart';
import 'package:olx_clone/providers/auth_provider.dart';

class PremiumPackageProvider extends ChangeNotifier {
  final AuthProviderApp _authProvider;
  final String _apiBaseUrl = 'https://olx-api-production.up.railway.app/api';

  List<PremiumPackage> _packages = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedPackageIndex = 0;

  PremiumPackageProvider(this._authProvider);

  List<PremiumPackage> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedPackageIndex => _selectedPackageIndex;
  PremiumPackage? get selectedPackage =>
      _packages.isNotEmpty && _selectedPackageIndex < _packages.length
          ? _packages[_selectedPackageIndex]
          : null;

  void selectPackage(int index) {
    if (index >= 0 && index < _packages.length) {
      _selectedPackageIndex = index;
      notifyListeners();
    }
  }

  Future<void> fetchPremiumPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/premium-packages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> packagesData = responseData['data'];
          _packages =
              packagesData
                  .map((json) => PremiumPackage.fromJson(json))
                  .where((package) => package.isActive)
                  .toList();
          _packages.sort((a, b) => a.price.compareTo(b.price));

          if (_packages.isNotEmpty) {
            _selectedPackageIndex = 0;
          }
        } else {
          _errorMessage =
              responseData['message'] ?? 'Gagal memuat paket premium';
        }
      } else {
        _errorMessage =
            'Gagal terhubung ke server. Kode: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createPremiumPayment(int packageId) async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      _errorMessage = 'Silakan login terlebih dahulu';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          '$_apiBaseUrl/payments/premium-subscriptions/$packageId/checkout',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final paymentUrl = responseData['data'];
          return paymentUrl.toString();
        } else {
          _errorMessage =
              responseData['message'] ?? 'Gagal membuat halaman pembayaran.';
        }
      } else {
        final responseData = json.decode(response.body);
        _errorMessage =
            responseData['message'] ??
            'Terjadi kesalahan: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> verifyPaymentSuccess(int packageId) async {
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          '$_apiBaseUrl/payments/premium-subscriptions/$packageId/verify',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return true;
        } else {
          _errorMessage =
              responseData['message'] ?? 'Verifikasi pembayaran gagal.';
          return false;
        }
      } else {
        final responseData = json.decode(response.body);
        _errorMessage =
            responseData['message'] ??
            'Terjadi kesalahan verifikasi: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _packages.clear();
    _selectedPackageIndex = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
