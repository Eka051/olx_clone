import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:olx_clone/models/user.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ProfileProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final String _baseUrl =
      'https://olx-api-production.up.railway.app/api/users/me';
  final AuthProviderApp _authProvider;
  static const String _userKey = 'user_profile_data';
  bool _disposed = false;

  ProfileProvider(this._authProvider) {
    _loadUserFromStorage();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
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

  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    if (_disposed) return;
    _error = error;
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return _authProvider.jwtToken;
  }

  Future<void> fetchUserProfile() async {
    if (_disposed) return;

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

      if (_disposed) return;
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          _setError("Server mengembalikan respons kosong.");
          return;
        }

        try {
          final apiResponse = jsonDecode(response.body);
          if (apiResponse['success'] == true && apiResponse['data'] != null) {
            _user = User.fromJson(apiResponse['data']);
            await _saveUserToStorage();
            _setError(null);
          } else {
            _setError(apiResponse['message'] ?? "Gagal mengambil data profil.");
          }
        } catch (e) {
          _setError("Respons server tidak valid: ${e.toString()}");
        }
      } else {
        _setError("Error: ${response.statusCode}. Gagal terhubung ke server.");
      }
    } catch (e) {
      if (!_disposed) {
        _setError("Terjadi kesalahan: ${e.toString()}");
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_disposed) return;

    try {
      _setLoading(true);
      await _clearUserFromStorage();
      if (!_disposed) {
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        _setError("Gagal logout: ${e.toString()}");
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    File? profilePictureFile,
  }) async {
    if (_disposed) return false;

    _setLoading(true);
    _setError(null);

    final token = await _getToken();
    if (token == null) {
      _setError("Token tidak ditemukan. Silakan login kembali.");
      _setLoading(false);
      return false;
    }

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(_baseUrl));

      request.headers['Authorization'] = 'Bearer $token';

      if (name != null && name.trim().isNotEmpty) {
        request.fields['Name'] = name.trim();
      }

      if (email != null && email.trim().isNotEmpty) {
        request.fields['Email'] = email.trim();
      }

      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        request.fields['PhoneNumber'] = phoneNumber.trim();
      }

      if (profilePictureFile != null && await profilePictureFile.exists()) {
        String extension =
            profilePictureFile.path.split('.').last.toLowerCase();

        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'ProfilePicture',
              profilePictureFile.path,
              contentType: MediaType('image', extension),
            ),
          );
        } else {
          _setError(
            "Format gambar tidak didukung. Gunakan JPG, PNG, atau GIF.",
          );
          _setLoading(false);
          return false;
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (_disposed) return false;

      if (response.statusCode == 200) {
        try {
          final apiResponse = jsonDecode(response.body);

          if (apiResponse['success'] == true && apiResponse['data'] != null) {
            _user = User.fromJson(apiResponse['data']);
            await _saveUserToStorage();
            _setError(null);
            return true;
          } else {
            String errorMessage =
                apiResponse['message'] ?? "Gagal mengupdate profil.";
            _setError(errorMessage);
            return false;
          }
        } catch (e) {
          String errorMessage = "Respons server tidak valid: ${e.toString()}";
          _setError(errorMessage);
          return false;
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = jsonDecode(response.body);
          String errorMessage = errorResponse['message'] ?? "Data tidak valid.";
          _setError(errorMessage);
        } catch (e) {
          _setError("Request tidak valid. Periksa data yang dimasukkan.");
        }
        return false;
      } else if (response.statusCode == 401) {
        _setError("Sesi telah berakhir. Silakan login kembali.");
        await logout();
        return false;
      } else if (response.statusCode == 404) {
        _setError("Pengguna tidak ditemukan.");
        return false;
      } else {
        String errorMessage =
            "Error ${response.statusCode}: ${response.reasonPhrase ?? 'Gagal mengupdate profil'}";
        _setError(errorMessage);
        return false;
      }
    } on SocketException {
      String errorMessage =
          "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
      _setError(errorMessage);
      return false;
    } on HttpException catch (e) {
      String errorMessage = "Kesalahan jaringan: ${e.message}";
      _setError(errorMessage);
      return false;
    } catch (e) {
      if (!_disposed) {
        String errorMessage = "Terjadi kesalahan: ${e.toString()}";
        _setError(errorMessage);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserFromStorage() async {
    if (_disposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null && !_disposed) {
        _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      _setError("Gagal memuat data profil dari storage: ${e.toString()}");
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
      }
    } catch (e) {
      _setError("Gagal menyimpan data profil ke storage: ${e.toString()}");
    }
  }

  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      _setError("Gagal menghapus data profil dari storage: ${e.toString()}");
    }
  }

  Future<void> forceRefreshProfile() async {
    if (_disposed) return;

    await _clearUserFromStorage();
    if (!_disposed) {
      _user = null;
      notifyListeners();
      await fetchUserProfile();
    }
  }

  void updateUserLocally({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    ProfileType? profileType,
  }) {
    if (_disposed || _user == null) return;

    try {
      _user = _user!.copyWith(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
        profileType: profileType,
      );

      _saveUserToStorage();
      notifyListeners();
    } catch (e) {
      _setError('Gagal mengupdate data lokal: ${e.toString()}');
    }
  }

  void updateToPremium() {
    if (_disposed || _user == null) return;
    updateUserLocally(profileType: ProfileType.premium);
  }

  Future<void> refreshProfileAfterPremiumUpgrade() async {
    if (_disposed) return;

    // Force refresh from server to get the updated profile type
    await forceRefreshProfile();
  }

  void clearError() {
    if (_disposed) return;
    _setError(null);
  }

  bool _validateProfileData({
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    if (name != null && name.trim().isEmpty) {
      _setError("Nama tidak boleh kosong.");
      return false;
    }

    if (email != null && email.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email.trim())) {
        _setError("Format email tidak valid.");
        return false;
      }
    }

    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
      if (!phoneRegex.hasMatch(
        phoneNumber.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
      )) {
        _setError("Format nomor telepon tidak valid.");
        return false;
      }
    }

    return true;
  }

  Future<bool> updateProfileWithValidation({
    String? name,
    String? email,
    String? phoneNumber,
    File? profilePictureFile,
  }) async {
    if (_disposed) return false;

    if (!_validateProfileData(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    )) {
      return false;
    }

    return await updateProfile(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profilePictureFile: profilePictureFile,
    );
  }
}
