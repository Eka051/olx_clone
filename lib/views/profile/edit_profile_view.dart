import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:http/http.dart' as http;

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    final profileProvider = context.read<ProfileProvider>();
    _nameController.text = profileProvider.user?.name ?? '';
    _emailController.text = profileProvider.user?.email ?? '';
    _phoneController.text = profileProvider.user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).colors.background,
        appBar: AppBar(
          title: Text(
            'Edit Profil',
            style: AppTheme.of(context).textStyle.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.grey.withAlpha(51),
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileImageSection(context, profileProvider),
                    const SizedBox(height: 32),
                    _buildTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap Anda',
                      controller: _nameController,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Email',
                      hint: 'Masukkan email Anda',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Nomor Telepon',
                      hint: 'Masukkan nomor telepon Anda',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        if (value!.length < 10) {
                          return 'Nomor telepon minimal 10 digit';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomButton(context),
      ),
    );
  }

  Widget _buildProfileImageSection(
    BuildContext context,
    ProfileProvider profileProvider,
  ) {
    return Center(
      child: Column(
        children: [
          Text(
            'Foto Profil',
            style: AppTheme.of(context).textStyle.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.of(context).colors.primary,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child:
                    _selectedImage != null
                        ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                        : (profileProvider
                                .user
                                ?.profilePictureUrl
                                ?.isNotEmpty ==
                            true)
                        ? Image.network(
                          profileProvider.user!.profilePictureUrl!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(profileProvider);
                          },
                        )
                        : _buildDefaultAvatar(profileProvider),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _showImagePickerOptions,
            icon: Icon(
              Icons.camera_alt,
              color: AppTheme.of(context).colors.primary,
            ),
            label: Text(
              'Ubah Foto',
              style: TextStyle(
                color: AppTheme.of(context).colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ProfileProvider profileProvider) {
    return Container(
      width: 120,
      height: 120,
      color: AppTheme.of(context).colors.primary.withAlpha(25),
      child: Center(
        child: Text(
          (profileProvider.user != null &&
                  profileProvider.user!.name.isNotEmpty)
              ? profileProvider.user!.name[0].toUpperCase()
              : 'U',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppTheme.of(context).colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.of(context).textStyle.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTheme.of(context).textStyle.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.of(
              context,
            ).textStyle.bodyMedium.copyWith(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.of(context).colors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      'Simpan Perubahan',
                      style: AppTheme.of(
                        context,
                      ).textStyle.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pilih Foto Profil',
                  style: AppTheme.of(
                    context,
                  ).textStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).colors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.of(context).colors.primary.withAlpha(51),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.of(context).colors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.of(context).colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profileProvider = context.read<ProfileProvider>();
      String? profilePictureUrl;

      if (_selectedImage != null) {
        profilePictureUrl = await _uploadProfileImage(_selectedImage!);
      } else {
        profilePictureUrl = profileProvider.user?.profilePictureUrl;
      }
      final success = await profileProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber:
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
        profilePictureFile: _selectedImage,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.error ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://olx-api-production.up.railway.app/api/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('ProfilePicture', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
