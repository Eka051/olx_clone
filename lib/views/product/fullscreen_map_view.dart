import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:olx_clone/utils/theme.dart';

class FullscreenMapView extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onLocationSelected;

  const FullscreenMapView({
    super.key,
    required this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<FullscreenMapView> createState() => _FullscreenMapViewState();
}

class _FullscreenMapViewState extends State<FullscreenMapView> {
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {},
            onCameraIdle: () {
              if (mounted) {
                final LatLng currentPosition =
                    _selectedPosition ?? widget.initialPosition;
                setState(() {
                  _selectedPosition = currentPosition;
                });
              }
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _selectedPosition = position.target;
              });
            },
            markers: {},
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            mapType: MapType.normal,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Geser peta untuk memilih lokasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.location_on,
                  size: 50,
                  color: AppTheme.of(context).colors.primary,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: "close_fullscreen_button",
              mini: true,
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              child: Icon(Icons.close, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedPosition != null) {
                  widget.onLocationSelected(_selectedPosition!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).colors.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pilih Lokasi Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
