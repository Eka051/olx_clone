import 'dart:io';
import 'package:flutter/material.dart';
import 'package:olx_clone/models/category.dart';

class CreateProductProvider extends ChangeNotifier {
  String _title = '';
  String _description = '';
  String _price = '';
  String _location = '';
  String _categoryId = '';
  Category? _selectedCategory;
  List<File> _images = [];

  bool _isUploading = false;
  String? _errorMessage;
  bool _isFormValid = false;

  // Text controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Getters
  String get title => _title;
  String get description => _description;
  String get price => _price;
  String get location => _location;
  String get categoryId => _categoryId;
  Category? get selectedCategory => _selectedCategory;
  List<File> get images => _images;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _isFormValid;
  bool get hasImages => _images.isNotEmpty;
  int get imagesCount => _images.length;

  CreateProductProvider() {
    // Listen to text controller changes
    titleController.addListener(_onTitleChanged);
    descriptionController.addListener(_onDescriptionChanged);
    priceController.addListener(_onPriceChanged);
    locationController.addListener(_onLocationChanged);

    // Set default location
    _location = 'Jakarta Selatan, DKI Jakarta';
    locationController.text = _location;
  }

  void _onTitleChanged() {
    _title = titleController.text;
    _validateForm();
  }

  void _onDescriptionChanged() {
    _description = descriptionController.text;
    _validateForm();
  }

  void _onPriceChanged() {
    final text = priceController.text;
    // Format price input
    final numbersOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbersOnly.isNotEmpty) {
      final formatted = _formatPrice(int.parse(numbersOnly));
      if (formatted != text) {
        priceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      _price = numbersOnly;
    } else {
      _price = '';
    }
    _validateForm();
  }

  void _onLocationChanged() {
    _location = locationController.text;
    _validateForm();
  }

  String _formatPrice(int price) {
    if (price == 0) return '';
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _validateForm() {
    _isFormValid =
        _title.isNotEmpty &&
        _description.isNotEmpty &&
        _price.isNotEmpty &&
        _location.isNotEmpty &&
        _categoryId.isNotEmpty &&
        _images.isNotEmpty;
    notifyListeners();
  }

  void setCategory(Category category) {
    _selectedCategory = category;
    _categoryId = category.id.toString();
    _validateForm();
  }

  void setLocation(String newLocation) {
    _location = newLocation;
    locationController.text = newLocation;
    _validateForm();
  }

  Future<void> pickImages() async {
    try {
      // Simulate image picking
      // In real implementation, use image_picker package
      await Future.delayed(const Duration(milliseconds: 500));

      // For demo, we'll create mock files (you should replace this with actual image picker)
      // _images.add(File('path/to/image.jpg'));

      _errorMessage =
          'Fitur pemilihan gambar akan diimplementasikan dengan image_picker package';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memilih gambar: $e';
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      // Simulate camera capture
      // In real implementation, use image_picker package
      await Future.delayed(const Duration(milliseconds: 500));

      _errorMessage =
          'Fitur kamera akan diimplementasikan dengan image_picker package';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal mengambil foto: $e';
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      _validateForm();
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final File item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }

  Future<bool> submitProduct() async {
    if (!_isFormValid || _isUploading) return false;

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate data
      if (_title.trim().length < 3) {
        throw Exception('Judul minimal 3 karakter');
      }
      if (_description.trim().length < 10) {
        throw Exception('Deskripsi minimal 10 karakter');
      }
      if (int.parse(_price) < 1000) {
        throw Exception('Harga minimal Rp 1.000');
      }
      if (_images.isEmpty) {
        throw Exception('Minimal 1 foto produk');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // For now, we'll simulate success
      // In real implementation:
      // final success = await ApiService.createProduct(
      //   title: _title,
      //   description: _description,
      //   price: int.parse(_price),
      //   categoryId: _categoryId,
      //   location: _location,
      //   images: _images,
      // );

      // Simulate success
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    _title = '';
    _description = '';
    _price = '';
    _categoryId = '';
    _selectedCategory = null;
    _images.clear();
    _errorMessage = null;

    titleController.clear();
    descriptionController.clear();
    priceController.clear();

    _validateForm();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
