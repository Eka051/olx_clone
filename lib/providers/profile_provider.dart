import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:olx_clone/models/user.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class ProfileProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final String _baseUrl = 'https://olx-api.azurewebsites.net/api/users/me';
  final AuthProviderApp _authProvider;

  ProfileProvider(this._authProvider);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return _authProvider.jwtToken;
  }

  Future<void> fetchUserProfile() async {
    _setLoading(true);
    _setError(null);

    final token = await _getToken();
    if (token == null) {
      _setError("Token tidak ditemukan. Silakan login kembali.");
      _setLoading(false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          _user = User.fromJson(apiResponse['data']);
        } else {
          _setError(apiResponse['message'] ?? "Gagal mengambil data profil.");
        }
      } else {
        _setError("Error: ${response.statusCode}. Gagal terhubung ke server.");
      }
    } catch (e) {
      _setError("Terjadi kesalahan: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authProvider.logout();
  }

  Future<void> updateProfile({String? name, String? phoneNumber}) async {
    _setLoading(true);
    _setError(null);

    final token = await _getToken();
    if (token == null) {
      _setError("Token tidak ditemukan. Silakan login kembali.");
      _setLoading(false);
      return;
    }

    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          _user = User.fromJson(apiResponse['data']);
        } else {
          _setError(apiResponse['message'] ?? "Gagal mengupdate profil.");
        }
      } else {
        _setError("Error: ${response.statusCode}. Gagal mengupdate profil.");
      }
    } catch (e) {
      _setError("Terjadi kesalahan: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }
}
