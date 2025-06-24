import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleGeocodingService {
  static String get _apiKey => dotenv.env['GMAPS_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  static Future<Map<String, dynamic>?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key not found in .env file');
    }

    try {
      final url =
          '$_baseUrl?latlng=$latitude,$longitude&key=$_apiKey&language=id';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return _parseGeocodingResult(result);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCoordinatesFromAddress(
    String address,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key not found in .env file');
    }

    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = '$_baseUrl?address=$encodedAddress&key=$_apiKey&language=id';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];

          return {
            'latitude': location['lat'],
            'longitude': location['lng'],
            ..._parseGeocodingResult(result),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> _parseGeocodingResult(
    Map<String, dynamic> result,
  ) {
    String address = result['formatted_address'] ?? '';
    String district = '';
    String city = '';
    String province = '';
    String postalCode = '';
    String country = '';

    final components = result['address_components'] as List<dynamic>? ?? [];

    for (final component in components) {
      final types = List<String>.from(component['types'] ?? []);
      final longName = component['long_name'] ?? '';

      if (types.contains('administrative_area_level_4') ||
          types.contains('sublocality_level_1')) {
        district = longName;
      } else if (types.contains('administrative_area_level_2') ||
          types.contains('locality')) {
        city = longName;
      } else if (types.contains('administrative_area_level_1')) {
        province = longName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      } else if (types.contains('country')) {
        country = longName;
      }
    }

    return {
      'address': address,
      'district': district,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'country': country,
    };
  }

  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key not found in .env file');
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '$_baseUrl?address=$encodedQuery&key=$_apiKey&language=id&components=country:ID';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          return results.map((result) {
            final location = result['geometry']['location'];
            return {
              'latitude': location['lat'],
              'longitude': location['lng'],
              ..._parseGeocodingResult(result),
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> testApiKeyLoaded() async {
    try {
      final apiKey = dotenv.env['GMAPS_API_KEY'];
      return apiKey != null && apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
