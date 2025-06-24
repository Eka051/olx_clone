import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/premium_package.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/views/payment/payment_webview.dart';
import 'package:provider/provider.dart';

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

  Future<void> handleSubscription(BuildContext context) async {
    if (selectedPackage == null) return;
    if (!_authProvider.isLoggedIn || _authProvider.jwtToken == null) {
      _showErrorSnackbar(context, 'Silakan login terlebih dahulu');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          '$_apiBaseUrl/payments/premium-subscriptions/${selectedPackage!.id}/checkout',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authProvider.jwtToken}',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 && context.mounted) {
        if (responseData['data'] != null &&
            responseData['data']['paymentUrl'] != null &&
            responseData['data']['finishUrl'] != null) {
          final String paymentUrl = responseData['data']['paymentUrl'];
          final String finishUrl = responseData['data']['finishUrl'];

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PaymentWebview(
                    paymentUrl: paymentUrl,
                    finishUrl: finishUrl,
                  ),
            ),
          );

          debugPrint(finishUrl);

          if (result == 'success' && context.mounted) {
            _showVerifyingDialog(context);
            await context
                .read<ProfileProvider>()
                .refreshProfileAfterPremiumUpgrade();
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            if (context.mounted) {
              _showSuccessSnackbar(context, 'Berhasil berlangganan premium!');
            }
            return;
          } else if (context.mounted) {
            _showSuccessSnackbar(context, 'Berhasil berlangganan premium!');
          }
        } else {
          _errorMessage =
              responseData['message'] ?? 'Gagal membuat halaman pembayaran.';
          if (context.mounted) _showErrorSnackbar(context, _errorMessage!);
        }
      } else {
        _errorMessage =
            responseData['message'] ??
            'Terjadi kesalahan: ${response.statusCode}';
        if (context.mounted) _showErrorSnackbar(context, _errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      if (context.mounted) _showErrorSnackbar(context, _errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showVerifyingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const PopScope(
            canPop: false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memverifikasi pembayaran...'),
                ],
              ),
            ),
          ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
