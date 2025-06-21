import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/models/category.dart';
import 'package:olx_clone/models/product.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:olx_clone/views/product/fullscreen_map_view.dart';
import 'package:intl/intl.dart';

class CreateProductView extends StatefulWidget {
  final Category? selectedCategory;
  final bool isEdit;
  final Product? product;

  const CreateProductView({
    super.key,
    this.selectedCategory,
    this.isEdit = false,
    this.product,
  });

  @override
  State<CreateProductView> createState() => _CreateProductViewState();
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    int value = int.parse(newText);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String formattedText = formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _CreateProductViewState extends State<CreateProductView> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  ProductProvider? _productProvider;

  @override
  void initState() {
    super.initState();

    _productProvider = context.read<ProductProvider>();

    // Use post-frame callbacks to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.isEdit && widget.product != null) {
        _productProvider?.setProductData(widget.product!);
        if (widget.selectedCategory != null) {
          _productProvider?.setCategory(widget.selectedCategory!);
        }
        // Trigger rebuild after data is set
        if (mounted) {
          setState(() {});
        }
      } else if (widget.selectedCategory != null) {
        _productProvider?.setCategory(widget.selectedCategory!);
      }

      // Also handle location data if available
      if (_productProvider?.latitude != null &&
          _productProvider?.longitude != null) {
        _selectedLocation = LatLng(
          _productProvider!.latitude!,
          _productProvider!.longitude!,
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.of(context).colors.primary,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).colors.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(deviceHeight * 0.07),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              String title = 'Pasang Iklan';

              if (widget.isEdit) {
                if (productProvider.category != null) {
                  title = productProvider.category!.name;
                } else if (widget.product != null &&
                    widget.product!.categoryName.isNotEmpty) {
                  title = widget.product!.categoryName;
                } else if (widget.selectedCategory != null) {
                  title = widget.selectedCategory!.name;
                }
              } else {
                if (productProvider.category != null) {
                  title = productProvider.category!.name;
                } else if (widget.selectedCategory != null) {
                  title = widget.selectedCategory!.name;
                }
              }

              return AppBar(
                backgroundColor: AppTheme.of(context).colors.surface,
                foregroundColor: Colors.black,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  title,
                  style: AppTheme.of(context).textStyle.titleLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(
                    color: AppTheme.of(context).colors.grey,
                    height: 1,
                  ),
                ),
              );
            },
          ),
        ),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            return Column(
              children: [
                _buildStepIndicator(deviceWidth, productProvider.currentStep),
                Expanded(
                  child: IndexedStack(
                    index: productProvider.currentStep,
                    children: [
                      _buildStep1PhotoUpload(
                        context,
                        productProvider,
                        deviceWidth,
                      ),
                      _buildStep2LocationSelection(
                        context,
                        productProvider,
                        deviceWidth,
                      ),
                      _buildStep3ProductDetails(
                        context,
                        productProvider,
                        deviceWidth,
                      ),
                    ],
                  ),
                ),
                _buildBottomNavigationBar(
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

  Widget _buildStepIndicator(double deviceWidth, int currentStep) {
    return Padding(
      padding: EdgeInsets.all(deviceWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle('01', currentStep >= 0, deviceWidth),
          _buildDottedLine(deviceWidth),
          _buildStepCircle('02', currentStep >= 1, deviceWidth),
          _buildDottedLine(deviceWidth),
          _buildStepCircle('03', currentStep >= 2, deviceWidth),
        ],
      ),
    );
  }

  Widget _buildStepCircle(String number, bool isActive, double deviceWidth) {
    return Container(
      width: deviceWidth * 0.12,
      height: deviceWidth * 0.12,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.of(context).colors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isActive
                  ? AppTheme.of(context).colors.primary
                  : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: deviceWidth * 0.035,
          ),
        ),
      ),
    );
  }

  Widget _buildDottedLine(double deviceWidth) {
    return SizedBox(
      width: deviceWidth * 0.15,
      height: 2,
      child: CustomPaint(painter: DottedLinePainter()),
    );
  }

  Widget _buildStep1PhotoUpload(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
  ) {
    return Padding(
      padding: EdgeInsets.all(deviceWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unggah Foto Iklan',
            style: AppTheme.of(context).textStyle.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.of(context).colors.primaryTextColor,
              fontSize: deviceWidth * 0.055,
            ),
          ),
          SizedBox(height: deviceWidth * 0.02),
          Text(
            'Foto Anda akan menjadi sampul/thumbnail iklan',
            style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
              color: AppTheme.of(context).colors.secondaryTextColor,
              fontSize: deviceWidth * 0.035,
            ),
          ),
          SizedBox(height: deviceWidth * 0.06),
          _buildPhotoGrid(context, productProvider, deviceWidth),
          SizedBox(height: deviceWidth * 0.04),
          Text(
            'Minimal 1 foto, maksimal 3 foto',
            style: AppTheme.of(context).textStyle.bodySmall.copyWith(
              color: AppTheme.of(context).colors.secondaryTextColor,
              fontSize: deviceWidth * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2LocationSelection(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
  ) {
    if (productProvider.latitude != null && productProvider.longitude != null) {
      _selectedLocation = LatLng(
        productProvider.latitude!,
        productProvider.longitude!,
      );
    }

    return Padding(
      padding: EdgeInsets.all(deviceWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Lokasi',
            style: AppTheme.of(context).textStyle.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.of(context).colors.primaryTextColor,
              fontSize: deviceWidth * 0.055,
            ),
          ),
          SizedBox(height: deviceWidth * 0.02),
          Text(
            'Tentukan lokasi iklan Anda',
            style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
              color: AppTheme.of(context).colors.secondaryTextColor,
              fontSize: deviceWidth * 0.035,
            ),
          ),
          SizedBox(height: deviceWidth * 0.06),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(deviceWidth * 0.04),
            margin: EdgeInsets.only(bottom: deviceWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.of(context).colors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi Terpilih',
                        style: AppTheme.of(context).textStyle.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (productProvider.isLoadingLocation)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.of(context).colors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  productProvider.formattedAddress.isNotEmpty
                      ? productProvider.formattedAddress
                      : productProvider.isLoadingLocation
                      ? 'Mengambil alamat...'
                      : 'Tekan "Gunakan Lokasi Saat Ini" atau tap pada peta untuk memilih lokasi',
                  style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                    color: AppTheme.of(context).colors.secondaryTextColor,
                    fontSize: deviceWidth * 0.04,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target:
                            productProvider.latitude != null &&
                                    productProvider.longitude != null
                                ? LatLng(
                                  productProvider.latitude!,
                                  productProvider.longitude!,
                                )
                                : LatLng(-6.2088, 106.8456),
                        zoom: 16,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        if (productProvider.latitude != null &&
                            productProvider.longitude != null) {
                          _selectedLocation = LatLng(
                            productProvider.latitude!,
                            productProvider.longitude!,
                          );
                        }
                      },
                      onTap: (LatLng tappedPoint) async {
                        if (!mounted) return;

                        setState(() {
                          _selectedLocation = tappedPoint;
                        });

                        final provider = context.read<ProductProvider>();
                        await provider.updateLocationFromCoordinates(
                          tappedPoint.latitude,
                          tappedPoint.longitude,
                        );
                      },
                      markers:
                          _selectedLocation != null
                              ? {
                                Marker(
                                  markerId: MarkerId('selected_location'),
                                  position: _selectedLocation!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                ),
                              }
                              : {},
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: true,
                      tiltGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      mapType: MapType.normal,
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: FloatingActionButton(
                        heroTag: "fullscreen_map_button",
                        mini: true,
                        onPressed: () => _openFullscreenMap(productProvider),
                        backgroundColor: AppTheme.of(context).colors.primary,
                        child: Icon(
                          Icons.fullscreen,
                          color: AppTheme.of(context).colors.onPrimary,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (!mounted) return;

                          final provider = context.read<ProductProvider>();
                          String? error =
                              await provider.getCurrentLocationWithFeedback();

                          if (!mounted) return;

                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else if (_mapController != null &&
                              provider.latitude != null &&
                              provider.longitude != null) {
                            final newPosition = LatLng(
                              provider.latitude!,
                              provider.longitude!,
                            );
                            setState(() {
                              _selectedLocation = newPosition;
                            });
                            await _mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(target: newPosition, zoom: 16),
                              ),
                            );
                          }
                        },
                        icon:
                            productProvider.isLoadingLocation
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Icon(Icons.my_location),
                        label: Text(
                          productProvider.isLoadingLocation
                              ? 'Mengambil lokasi...'
                              : 'Gunakan Lokasi Saat Ini',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.of(context).colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3ProductDetails(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
  ) {
    return Padding(
      padding: EdgeInsets.all(deviceWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Iklan',
            style: AppTheme.of(context).textStyle.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.of(context).colors.primaryTextColor,
              fontSize: deviceWidth * 0.055,
            ),
          ),
          SizedBox(height: deviceWidth * 0.02),
          Text(
            'Lengkapi informasi iklan Anda',
            style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
              color: AppTheme.of(context).colors.secondaryTextColor,
              fontSize: deviceWidth * 0.035,
            ),
          ),
          SizedBox(height: deviceWidth * 0.06),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Judul Iklan',
                    hint: 'Contoh: iPhone 13 Pro Max 256GB',
                    value: productProvider.title,
                    onChanged: productProvider.setTitle,
                    maxLines: 1,
                  ),
                  SizedBox(height: deviceWidth * 0.04),
                  _buildTextField(
                    label: 'Deskripsi',
                    hint: 'Deskripsikan kondisi dan detail barang Anda...',
                    value: productProvider.description,
                    onChanged: productProvider.setDescription,
                    maxLines: 5,
                  ),
                  SizedBox(height: deviceWidth * 0.04),
                  if (productProvider.shouldShowPrice)
                    _buildTextField(
                      label: 'Harga',
                      hint: 'Masukkan harga (Rp)',
                      value:
                          productProvider.price > 0
                              ? NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(productProvider.price)
                              : '',
                      onChanged: (value) {
                        String numericValue = value.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        if (numericValue.isNotEmpty) {
                          productProvider.setPrice(double.parse(numericValue));
                        } else {
                          productProvider.setPrice(0);
                        }
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMainPhotoSlot(context, productProvider, deviceWidth),
        ),
        SizedBox(width: deviceWidth * 0.03),
        Expanded(
          child: _buildAdditionalPhotoSlot(
            context,
            productProvider,
            deviceWidth,
            0,
          ),
        ),
        SizedBox(width: deviceWidth * 0.03),
        Expanded(
          child: _buildAdditionalPhotoSlot(
            context,
            productProvider,
            deviceWidth,
            1,
          ),
        ),
      ],
    );
  }

  Widget _buildMainPhotoSlot(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
  ) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(0, productProvider),
      child: Container(
        height: deviceWidth * 0.25,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _hasImageAtIndex(0, productProvider)
                    ? AppTheme.of(context).colors.primary
                    : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _hasImageAtIndex(0, productProvider) ? null : Colors.grey[50],
        ),
        child:
            _hasImageAtIndex(0, productProvider)
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImageAtIndex(0, productProvider),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: deviceWidth * 0.08,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: deviceWidth * 0.02),
                    Text(
                      'Sampul',
                      style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                        color: Colors.grey[500],
                        fontSize: deviceWidth * 0.03,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildAdditionalPhotoSlot(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
    int index,
  ) {
    final actualIndex = index + 1;
    return GestureDetector(
      onTap: () => _showImagePickerOptions(actualIndex, productProvider),
      child: Container(
        height: deviceWidth * 0.25,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _hasImageAtIndex(actualIndex, productProvider)
                    ? AppTheme.of(context).colors.primary
                    : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              _hasImageAtIndex(actualIndex, productProvider)
                  ? null
                  : Colors.grey[50],
        ),
        child:
            _hasImageAtIndex(actualIndex, productProvider)
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImageAtIndex(actualIndex, productProvider),
                )
                : Icon(
                  Icons.add,
                  size: deviceWidth * 0.08,
                  color: Colors.grey[400],
                ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    required String value,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!, width: 1),
          ),
          child: TextField(
            controller: TextEditingController(text: value)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: value.length),
              ),
            maxLines: maxLines,
            keyboardType: keyboardType,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                color: AppTheme.of(context).colors.hintTextColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: AppTheme.of(context).textStyle.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions(int index, ProductProvider productProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(
                    ImageSource.camera,
                    index,
                    productProvider,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(
                    ImageSource.gallery,
                    index,
                    productProvider,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromSource(
    ImageSource source,
    int index,
    ProductProvider productProvider,
  ) async {
    await productProvider.pickImage(index, source: source);
  }

  void _openFullscreenMap(ProductProvider productProvider) {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullscreenMapView(
              initialPosition:
                  productProvider.latitude != null &&
                          productProvider.longitude != null
                      ? LatLng(
                        productProvider.latitude!,
                        productProvider.longitude!,
                      )
                      : LatLng(-6.2088, 106.8456),
              onLocationSelected: (LatLng selectedLocation) {
                productProvider.updateLocationFromCoordinates(
                  selectedLocation.latitude,
                  selectedLocation.longitude,
                );
              },
            ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    ProductProvider productProvider,
    double deviceWidth,
    double deviceHeight,
  ) {
    return Container(
      padding: EdgeInsets.all(deviceWidth * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.of(context).colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (productProvider.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: productProvider.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: deviceWidth * 0.04),
                  side: BorderSide(color: AppTheme.of(context).colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                    color: AppTheme.of(context).colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (productProvider.currentStep > 0)
            SizedBox(width: deviceWidth * 0.04),
          Expanded(
            flex: productProvider.currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _getNextButtonAction(productProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _getNextButtonAction(productProvider) != null
                        ? AppTheme.of(context).colors.primary
                        : Colors.grey[400],
                padding: EdgeInsets.symmetric(vertical: deviceWidth * 0.04),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  productProvider.isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        productProvider.getNextButtonText(
                          productProvider.currentStep,
                          widget.isEdit,
                        ),
                        style: AppTheme.of(
                          context,
                        ).textStyle.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _getNextButtonAction(ProductProvider productProvider) {
    switch (productProvider.currentStep) {
      case 0:
        return productProvider.isStep1Valid() ? productProvider.nextStep : null;
      case 1:
        return productProvider.isStep2Valid() ? productProvider.nextStep : null;
      case 2:
        return productProvider.isStep3Valid()
            ? () async {
              await productProvider.submitProductWithContext(context);
            }
            : null;
      default:
        return null;
    }
  }

  bool _hasImageAtIndex(int index, ProductProvider productProvider) {
    return productProvider.hasImageAtIndex(index);
  }

  Widget _buildImageAtIndex(int index, ProductProvider productProvider) {
    String? imagePath = productProvider.getImagePathAtIndex(index);
    if (imagePath == null) {
      return const SizedBox();
    }

    if (productProvider.isImageLocal(index)) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 40,
            ),
          );
        },
      );
    }
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[400]!
          ..strokeWidth = 2;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
