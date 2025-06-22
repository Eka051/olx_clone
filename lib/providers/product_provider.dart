import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:olx_clone/models/category.dart' as model;
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/services/google_geocoding_service.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';

class ProductProvider extends ChangeNotifier {
  final AuthProviderApp _authProvider;
  final ProfileProvider _profileProvider;

  ProductProvider(this._authProvider, this._profileProvider);

  int _currentStep = 0;
  final List<File> _images = [];
  List<String> _originalImages = [];
  bool _isEdit = false;
  int? _editProductId;
  String? productId;
  String _title = '';
  String _description = '';
  double _price = 0.0;
  model.Category? _category;

  double? _latitude;
  double? _longitude;
  String _address = '';
  String _district = '';
  String _city = '';
  String _province = '';
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _isSold = false;
  final bool _isActive = true;
  bool _shouldRefreshMyAds = false;
  String? _lastError;

  Set<int> _favoriteProductIds = {};

  final ImagePicker _imagePicker = ImagePicker();
  final String _apiBaseUrl = 'https://olx-api-production.up.railway.app/api';

  int get currentStep => _currentStep;
  List<File> get images => _images;
  List<String> get originalImages => _originalImages;
  bool get isEdit => _isEdit;
  String get title => _title;
  String get description => _description;
  double get price => _price;
  model.Category? get category => _category;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get address => _address;
  String get district => _district;
  String get city => _city;
  String get province => _province;
  bool get isLoading => _isLoading;
  bool get isSold => _isSold;
  bool get isActive => _isActive;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get shouldRefreshMyAds => _shouldRefreshMyAds;
  Set<int> get favoriteProductIds => _favoriteProductIds;
  String? get lastError => _lastError;

  String? get currentUserId => _profileProvider.user?.id;

  bool isCurrentUserOwner(Product product) {
    final currentUserId = _profileProvider.user?.id;
    if (currentUserId == null) return false;
    return currentUserId == product.sellerId || currentUserId == product.userId;
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      notifyListeners();
    }
  }

  String? validateStep1() {
    if (_images.isEmpty && (_isEdit ? _originalImages.isEmpty : true)) {
      return 'Silakan pilih minimal 1 foto untuk iklan Anda';
    }
    return null;
  }

  String? validateStep2() {
    if (_isEdit) {
      return null;
    }
    if (_latitude == null || _longitude == null) {
      return 'Silakan pilih lokasi iklan Anda';
    }
    if (formattedAddress.isEmpty) {
      return 'Alamat tidak dapat dimuat, silakan coba lagi';
    }
    return null;
  }

  String? validateStep3() {
    if (_title.trim().isEmpty) {
      return 'Judul iklan tidak boleh kosong';
    }
    if (_title.trim().length < 5) {
      return 'Judul iklan minimal 5 karakter';
    }
    if (_description.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    if (_description.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }

    if (_category == null) {
      return 'Kategori harus dipilih';
    }

    if (shouldShowPrice && _price <= 0) {
      return 'Harga harus lebih dari 0';
    }

    return null;
  }

  String? validateAllSteps() {
    String? step1Error = validateStep1();
    if (step1Error != null) return 'Step 1: $step1Error';

    String? step2Error = validateStep2();
    if (step2Error != null) return 'Step 2: $step2Error';

    String? step3Error = validateStep3();
    if (step3Error != null) return 'Step 3: $step3Error';

    return null;
  }

  bool isStep1Valid() {
    return validateStep1() == null;
  }

  bool isStep2Valid() {
    return validateStep2() == null;
  }

  bool isStep3Valid() {
    return validateStep3() == null;
  }

  Future<void> pickImage(
    int index, {
    ImageSource source = ImageSource.gallery,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      if (_isEdit) {
        int totalExistingImages = _originalImages.length + _images.length;
        if (index >= totalExistingImages) {
          _images.add(imageFile);
        } else if (index >= _originalImages.length) {
          int newImageIndex = index - _originalImages.length;
          if (newImageIndex < _images.length) {
            _images[newImageIndex] = imageFile;
          } else {
            _images.add(imageFile);
          }
        } else {
          _images.add(imageFile);
        }
      } else {
        if (index < _images.length) {
          _images[index] = imageFile;
        } else {
          _images.add(imageFile);
        }
      }

      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await updateLocationFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateLocationFromCoordinates(double lat, double lng) async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final result = await GoogleGeocodingService.getAddressFromCoordinates(
        lat,
        lng,
      );

      if (result != null) {
        setLocation(
          lat,
          lng,
          result['address'] ?? 'Alamat tidak ditemukan',
          dist: result['district'] ?? '',
          ct: result['city'] ?? '',
          prov: result['province'] ?? '',
        );
      } else {
        setLocation(lat, lng, 'Alamat tidak dapat dimuat');
      }
    } catch (e) {
      setLocation(lat, lng, 'Alamat tidak dapat dimuat');
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void setLocation(
    double lat,
    double lng,
    String addr, {
    String? dist,
    String? ct,
    String? prov,
  }) {
    _latitude = lat;
    _longitude = lng;
    _address = addr;
    _district = dist ?? '';
    _city = ct ?? '';
    _province = prov ?? '';
    notifyListeners();
  }

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setDescription(String description) {
    _description = description;
    notifyListeners();
  }

  void setPrice(double price) {
    _price = price;
    notifyListeners();
  }

  void setCategory(model.Category category) {
    _category = category;
    notifyListeners();
  }

  void setProductData(Product product) {
    _isEdit = true;
    _editProductId = product.id;
    _title = product.title;
    _description = product.description;
    _price = product.price.toDouble();

    if (product.categoryId == 0 || product.categoryName.isEmpty) {
      _category = null;
    } else {
      _category = model.Category(
        id: product.categoryId,
        name: product.categoryName,
      );
    }

    _city = product.cityName;
    _province = product.provinceName;
    _district = product.districtName;
    _address =
        '${product.districtName}, ${product.cityName}, ${product.provinceName}';

    _latitude = -6.2088;
    _longitude = 106.8456;

    _images.clear();
    _originalImages = List.from(product.images);
  }

  bool get shouldShowPrice {
    return _category?.name.toLowerCase() != 'gratis';
  }

  String get formattedAddress {
    List<String> addressParts = [];

    if (_district.isNotEmpty) {
      addressParts.add(_district);
    }
    if (_city.isNotEmpty) {
      addressParts.add(_city);
    }
    if (_province.isNotEmpty) {
      addressParts.add(_province);
    }

    return addressParts.isNotEmpty ? addressParts.join(', ') : _address;
  }

  Future<String?> getCurrentLocationWithFeedback() async {
    bool success = await getCurrentLocation();
    if (!success) {
      return 'Gagal mendapatkan lokasi';
    }
    return null;
  }

  Future<bool> submitProduct() async {
    _lastError = null;

    String? validationError = validateAllSteps();
    if (validationError != null) {
      _lastError = validationError;
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = _authProvider.jwtToken;
      if (token == null) {
        _lastError = 'Token autentikasi tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (_isEdit && _editProductId != null) {
        return await _updateExistingProduct(token);
      } else {
        return await _createNewProduct(token);
      }
    } catch (e) {
      _lastError = 'Error submit product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _createNewProduct(String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/products'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['Title'] = _title;
      request.fields['Description'] = _description;
      request.fields['Price'] = _price.toInt().toString();
      request.fields['CategoryId'] = _category!.id.toString();
      request.fields['Latitude'] = _latitude!.toString();
      request.fields['Longitude'] = _longitude!.toString();
      for (var imageFile in _images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Images',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      } else {
        _lastError = 'HTTP ${response.statusCode}: ${response.body}';
        return false;
      }
    } catch (e) {
      _lastError = 'Error creating product: ${e.toString()}';
      return false;
    }
  }

  Future<bool> _updateExistingProduct(String token) async {
    try {
      if (_category == null) {
        _lastError = 'Kategori tidak boleh kosong';
        return false;
      }
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_apiBaseUrl/products/$_editProductId'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['Title'] = _title;
      request.fields['Description'] = _description;
      request.fields['Price'] = _price.toInt().toString();
      request.fields['CategoryId'] = _category!.id.toString();

      if (_latitude != null && _longitude != null) {
        request.fields['Latitude'] = _latitude!.toString();
        request.fields['Longitude'] = _longitude!.toString();
      }

      for (var imageFile in _images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Images',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        _lastError = 'HTTP ${response.statusCode}: ${response.body}';
        return false;
      }
    } catch (e) {
      _lastError = 'Error updating product: ${e.toString()}';
      return false;
    }
  }

  void reset() {
    _currentStep = 0;
    _images.clear();
    _originalImages.clear();
    _isEdit = false;
    _editProductId = null;
    _title = '';
    _description = '';
    _price = 0.0;
    _category = null;
    _latitude = null;
    _longitude = null;
    _address = '';
    _district = '';
    _city = '';
    _province = '';
    _favoriteProductIds.clear();
    _lastError = null;
    notifyListeners();
  }

  Future<List<Product>> getUserProducts({bool isMyAds = false}) async {
    try {
      final token = _authProvider.jwtToken;
      if (token == null) {
        return [];
      }

      String apiUrl = '$_apiBaseUrl/products';
      if (isMyAds) {
        apiUrl += '?isMyAds=true';
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final products = data.map((json) => Product.fromJson(json)).toList();
          return products;
        } else if (responseData is List) {
          final products =
              responseData.map((json) => Product.fromJson(json)).toList();
          return products;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> soldProduct(int productId) async {
    final token = _authProvider.jwtToken;
    if (token == null) {
      return;
    }

    final response = await http.patch(
      Uri.parse('$_apiBaseUrl/products/$productId/sold'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      _isSold = true;
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatus(int productId) async {
    if (_favoriteProductIds.contains(productId)) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }

  Future<void> addFavorite(int productId) async {
    final token = _authProvider.jwtToken;
    if (token == null) return;

    final response = await http.post(
      Uri.parse('$_apiBaseUrl/favorites/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      _favoriteProductIds.add(productId);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(int productId) async {
    final token = _authProvider.jwtToken;
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('$_apiBaseUrl/favorites/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      _favoriteProductIds.remove(productId);
      notifyListeners();
    }
  }

  Future<List<Product>> getFavoriteProducts() async {
    try {
      final token = _authProvider.jwtToken;
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final products = data.map((json) => Product.fromJson(json)).toList();
          _favoriteProductIds = products.map((p) => p.id).toSet();
          notifyListeners();
          return products;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateProduct(
    int productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = _authProvider.jwtToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('$_apiBaseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateProduct(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = _authProvider.jwtToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.patch(
        Uri.parse('$_apiBaseUrl/products/$productId/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to deactivate product: ${response.body}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = _authProvider.jwtToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String getNextButtonText(int currentStep, bool isEdit) {
    switch (currentStep) {
      case 0:
        return 'Lanjutkan';
      case 1:
        return 'Lanjutkan';
      case 2:
        return isEdit ? 'Simpan Perubahan' : 'Pasang Iklan';
      default:
        return 'Lanjutkan';
    }
  }

  bool hasImageAtIndex(int index) {
    int totalImages = _images.length + (_isEdit ? _originalImages.length : 0);
    return index < totalImages;
  }

  String? getImagePathAtIndex(int index) {
    if (_isEdit) {
      if (index < _originalImages.length) {
        return _originalImages[index];
      } else {
        int newImageIndex = index - _originalImages.length;
        if (newImageIndex < _images.length) {
          return _images[newImageIndex].path;
        }
      }
    } else {
      if (index < _images.length) {
        return _images[index].path;
      }
    }
    return null;
  }

  bool isImageLocal(int index) {
    if (_isEdit) {
      return index >= _originalImages.length;
    }
    return true;
  }

  Future<bool> submitProductWithContext(BuildContext context) async {
    try {
      bool success = await submitProduct();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Iklan berhasil diperbarui!'
                  : 'Iklan berhasil dipasang!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        reset();
        refreshMyAdsData();

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: {'initialTab': 3},
        );
        return true;
      } else if (context.mounted) {
        String errorMessage =
            _lastError ?? 'Gagal menyimpan iklan. Silakan coba lagi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
      return success;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  void refreshMyAdsData() {
    _shouldRefreshMyAds = true;
    notifyListeners();
  }

  void clearRefreshFlag() {
    _shouldRefreshMyAds = false;
    notifyListeners();
  }
}
