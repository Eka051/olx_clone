import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? initialData;

  const UploadProductScreen({super.key, this.productId, this.initialData});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _descController.text = widget.initialData!['description'] ?? '';
      _priceController.text = widget.initialData!['price']?.toString() ?? '';
      _locationController.text = widget.initialData!['location'] ?? '';
      _categoryController.text = widget.initialData!['category'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.initialData?['imageUrl'];
      if (_pickedImage != null) {
        final imageName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = FirebaseStorage.instance.ref().child('product_images/$imageName.jpg');
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final productData = {
        'judul': _titleController.text.trim(),
        'deskripsi': _descController.text.trim(),
        'harga': double.tryParse(_priceController.text) ?? 0,
        'lokasi': _locationController.text.trim(),
        'kategori': _categoryController.text.trim(),
        'gambarUrl': imageUrl,
        'userId': 1,
      };

      final response = await http.post(
        Uri.parse('https://your-api-url.com/api/produk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception('Gagal menyimpan data. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gagal simpan: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Iklan' : 'Jual Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: _pickedImage != null
                            ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                            : widget.initialData?['imageUrl'] != null
                                ? DecorationImage(image: NetworkImage(widget.initialData!['imageUrl']), fit: BoxFit.cover)
                                : null,
                      ),
                      child: _pickedImage == null && widget.initialData?['imageUrl'] == null
                          ? const Center(child: Icon(Icons.add_a_photo, size: 48, color: Colors.grey))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Judul Produk', filled: true),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Deskripsi', filled: true),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga', filled: true),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Lokasi', filled: true),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Kategori', filled: true),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(widget.productId != null ? 'Simpan Perubahan' : 'Upload Produk'),
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}