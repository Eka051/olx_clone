import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/create_product_provider.dart';
import 'package:olx_clone/models/category.dart';

class CreateProductView extends StatefulWidget {
  final Category? selectedCategory;

  const CreateProductView({super.key, this.selectedCategory});

  @override
  State<CreateProductView> createState() => _CreateProductViewState();
}

class _CreateProductViewState extends State<CreateProductView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedCategory != null) {
        context.read<CreateProductProvider>().setCategory(
          widget.selectedCategory!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.of(context).colors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).colors.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(deviceHeight * 0.07),
          child: AppBar(
            backgroundColor: AppTheme.of(context).colors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            title: Text(
              'Pasang Iklan',
              style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
        ),
        body: Consumer<CreateProductProvider>(
          builder: (context, productProvider, child) {
            return Column(
              children: [
                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(deviceWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photos Section
                        _buildPhotosSection(
                          context,
                          productProvider,
                          deviceWidth,
                        ),
                        SizedBox(height: deviceHeight * 0.03),

                        // Category Section
                        _buildCategorySection(
                          context,
                          productProvider,
                          deviceWidth,
                        ),
                        SizedBox(height: deviceHeight * 0.03),

                        // Product Details Section
                        _buildProductDetailsSection(
                          context,
                          productProvider,
                          deviceWidth,
                        ),
                        SizedBox(height: deviceHeight * 0.03),

                        // Location Section
                        _buildLocationSection(
                          context,
                          productProvider,
                          deviceWidth,
                        ),
                        SizedBox(
                          height: deviceHeight * 0.1,
                        ), // Extra space for button
                      ],
                    ),
                  ),
                ),

                // Submit Button
                _buildSubmitButton(
                  context,
                  productProvider,
                  deviceWidth,
                  deviceHeight,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotosSection(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Produk',
          style: AppTheme.of(context).textStyle.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.of(context).colors.primaryTextColor,
          ),
        ),
        SizedBox(height: deviceWidth * 0.02),
        Text(
          'Tambahkan hingga 10 foto. Foto pertama akan menjadi sampul iklan Anda.',
          style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
            color: AppTheme.of(context).colors.secondaryTextColor,
            fontSize: deviceWidth * 0.035,
          ),
        ),
        SizedBox(height: deviceWidth * 0.04),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              productProvider.hasImages
                  ? _buildImageGrid(context, productProvider, deviceWidth)
                  : _buildImagePlaceholder(
                    context,
                    productProvider,
                    deviceWidth,
                  ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Container(
      height: deviceWidth * 0.5,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: productProvider.pickImages,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(deviceWidth * 0.04),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_a_photo,
                  size: deviceWidth * 0.1,
                  color: AppTheme.of(context).colors.primary,
                ),
              ),
              SizedBox(height: deviceWidth * 0.04),
              Text(
                'Tambahkan Foto',
                style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                  color: AppTheme.of(context).colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: deviceWidth * 0.02),
              Text(
                'Ketuk untuk memilih foto dari galeri',
                style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                  color: AppTheme.of(context).colors.secondaryTextColor,
                  fontSize: deviceWidth * 0.035,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Padding(
      padding: EdgeInsets.all(deviceWidth * 0.04),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: deviceWidth * 0.02,
              mainAxisSpacing: deviceWidth * 0.02,
              childAspectRatio: 1,
            ),
            itemCount:
                productProvider.imagesCount +
                (productProvider.imagesCount < 10 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < productProvider.imagesCount) {
                return _buildImageItem(
                  context,
                  productProvider,
                  index,
                  deviceWidth,
                );
              } else {
                return _buildAddMoreButton(
                  context,
                  productProvider,
                  deviceWidth,
                );
              }
            },
          ),
          if (productProvider.errorMessage != null) ...[
            SizedBox(height: deviceWidth * 0.03),
            Container(
              padding: EdgeInsets.all(deviceWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[600],
                    size: deviceWidth * 0.05,
                  ),
                  SizedBox(width: deviceWidth * 0.02),
                  Expanded(
                    child: Text(
                      productProvider.errorMessage!,
                      style: AppTheme.of(
                        context,
                      ).textStyle.bodySmall.copyWith(color: Colors.red[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageItem(
    BuildContext context,
    CreateProductProvider productProvider,
    int index,
    double deviceWidth,
  ) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  index == 0
                      ? AppTheme.of(context).colors.primary
                      : Colors.grey[300]!,
              width: index == 0 ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              productProvider.images[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.error,
                    color: Colors.grey[400],
                    size: deviceWidth * 0.06,
                  ),
                );
              },
            ),
          ),
        ),

        // Main label for first image
        if (index == 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: deviceWidth * 0.02,
                vertical: deviceWidth * 0.008,
              ),
              decoration: BoxDecoration(
                color: AppTheme.of(context).colors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'UTAMA',
                style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: deviceWidth * 0.025,
                ),
              ),
            ),
          ),

        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => productProvider.removeImage(index),
            child: Container(
              padding: EdgeInsets.all(deviceWidth * 0.01),
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: deviceWidth * 0.04,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        color: Colors.grey[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: productProvider.pickImages,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: deviceWidth * 0.08,
                color: AppTheme.of(context).colors.primary,
              ),
              SizedBox(height: deviceWidth * 0.01),
              Text(
                'Tambah',
                style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                  color: AppTheme.of(context).colors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: deviceWidth * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: AppTheme.of(context).textStyle.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.of(context).colors.primaryTextColor,
          ),
        ),
        SizedBox(height: deviceWidth * 0.04),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context); // Go back to category selection
              },
              child: Padding(
                padding: EdgeInsets.all(deviceWidth * 0.04),
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: AppTheme.of(context).colors.primary,
                      size: deviceWidth * 0.06,
                    ),
                    SizedBox(width: deviceWidth * 0.04),
                    Expanded(
                      child: Text(
                        productProvider.selectedCategory?.name ??
                            'Pilih Kategori',
                        style: AppTheme.of(
                          context,
                        ).textStyle.bodyLarge.copyWith(
                          color:
                              productProvider.selectedCategory != null
                                  ? AppTheme.of(context).colors.primaryTextColor
                                  : AppTheme.of(context).colors.hintTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.of(context).colors.secondaryTextColor,
                      size: deviceWidth * 0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsSection(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Produk',
          style: AppTheme.of(context).textStyle.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.of(context).colors.primaryTextColor,
          ),
        ),
        SizedBox(height: deviceWidth * 0.04),

        // Title Field
        _buildTextField(
          context: context,
          controller: productProvider.titleController,
          label: 'Judul Iklan',
          hint: 'Contoh: iPhone 14 Pro Max 256GB Space Black',
          maxLength: 70,
          deviceWidth: deviceWidth,
        ),
        SizedBox(height: deviceWidth * 0.04),

        // Description Field
        _buildTextField(
          context: context,
          controller: productProvider.descriptionController,
          label: 'Deskripsi',
          hint: 'Jelaskan kondisi, spesifikasi, dan detail lainnya...',
          maxLines: 5,
          maxLength: 4000,
          deviceWidth: deviceWidth,
        ),
        SizedBox(height: deviceWidth * 0.04),

        // Price Field
        _buildTextField(
          context: context,
          controller: productProvider.priceController,
          label: 'Harga',
          hint: 'Rp 0',
          keyboardType: TextInputType.number,
          deviceWidth: deviceWidth,
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi',
          style: AppTheme.of(context).textStyle.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.of(context).colors.primaryTextColor,
          ),
        ),
        SizedBox(height: deviceWidth * 0.04),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Add location picker functionality
                _showLocationPicker(context, productProvider, deviceWidth);
              },
              child: Padding(
                padding: EdgeInsets.all(deviceWidth * 0.04),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.of(context).colors.primary,
                      size: deviceWidth * 0.06,
                    ),
                    SizedBox(width: deviceWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi Iklan',
                            style: AppTheme.of(
                              context,
                            ).textStyle.bodyMedium.copyWith(
                              color:
                                  AppTheme.of(
                                    context,
                                  ).colors.secondaryTextColor,
                              fontSize: deviceWidth * 0.035,
                            ),
                          ),
                          SizedBox(height: deviceWidth * 0.01),
                          Text(
                            productProvider.location,
                            style: AppTheme.of(
                              context,
                            ).textStyle.bodyLarge.copyWith(
                              color:
                                  AppTheme.of(context).colors.primaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.of(context).colors.secondaryTextColor,
                      size: deviceWidth * 0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required double deviceWidth,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.of(context).textStyle.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.of(context).colors.primaryTextColor,
          ),
        ),
        SizedBox(height: deviceWidth * 0.02),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                color: AppTheme.of(context).colors.hintTextColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(deviceWidth * 0.04),
              counterStyle: AppTheme.of(context).textStyle.bodySmall.copyWith(
                color: AppTheme.of(context).colors.secondaryTextColor,
                fontSize: deviceWidth * 0.032,
              ),
            ),
            style: AppTheme.of(context).textStyle.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
    double deviceHeight,
  ) {
    return Container(
      padding: EdgeInsets.all(deviceWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: deviceHeight * 0.065,
          child: ElevatedButton(
            onPressed:
                productProvider.isFormValid && !productProvider.isUploading
                    ? () => _submitProduct(context, productProvider)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).colors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                productProvider.isUploading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: deviceWidth * 0.05,
                          height: deviceWidth * 0.05,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: deviceWidth * 0.03),
                        Text(
                          'Mengunggah...',
                          style: AppTheme.of(
                            context,
                          ).textStyle.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Pasang Iklan Sekarang',
                      style: AppTheme.of(context).textStyle.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  void _showLocationPicker(
    BuildContext context,
    CreateProductProvider productProvider,
    double deviceWidth,
  ) {
    final locations = [
      'Jakarta Selatan, DKI Jakarta',
      'Jakarta Pusat, DKI Jakarta',
      'Jakarta Utara, DKI Jakarta',
      'Jakarta Barat, DKI Jakarta',
      'Jakarta Timur, DKI Jakarta',
      'Bogor, Jawa Barat',
      'Depok, Jawa Barat',
      'Tangerang, Banten',
      'Bekasi, Jawa Barat',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(deviceWidth * 0.04),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Pilih Lokasi',
                      style: AppTheme.of(
                        context,
                      ).textStyle.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.of(context).colors.primaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    final isSelected = location == productProvider.location;

                    return ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color:
                            isSelected
                                ? AppTheme.of(context).colors.primary
                                : AppTheme.of(
                                  context,
                                ).colors.secondaryTextColor,
                      ),
                      title: Text(
                        location,
                        style: AppTheme.of(
                          context,
                        ).textStyle.bodyMedium.copyWith(
                          color:
                              isSelected
                                  ? AppTheme.of(context).colors.primary
                                  : AppTheme.of(
                                    context,
                                  ).colors.primaryTextColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color: AppTheme.of(context).colors.primary,
                              )
                              : null,
                      onTap: () {
                        productProvider.setLocation(location);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: deviceWidth * 0.04),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitProduct(
    BuildContext context,
    CreateProductProvider productProvider,
  ) async {
    final success = await productProvider.submitProduct();

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: MediaQuery.of(context).size.width * 0.15,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.04),
                  Text(
                    'Iklan Berhasil Dipasang!',
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.of(context).colors.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'Iklan Anda sedang diproses dan akan segera tampil di OLX.',
                    style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                      color: AppTheme.of(context).colors.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to category
                    Navigator.of(context).pop(); // Go back to main screen
                  },
                  child: Text(
                    'OK',
                    style: AppTheme.of(context).textStyle.labelLarge.copyWith(
                      color: AppTheme.of(context).colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              productProvider.errorMessage ?? 'Gagal mengunggah iklan',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
