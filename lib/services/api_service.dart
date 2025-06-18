import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/api_message.dart';

class ApiService {
  static const String baseUrl = 'https://olx-api.azurewebsites.net';

  static Map<String, String> _getAuthHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<ApiMessage>> getMessages(String? authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Messages'),
        headers: _getAuthHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ApiMessage.fromJson(json)).toList();
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  static Future<bool> sendMessage({
    required String chatRoomId,
    required String content,
    required String? authToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Messages'),
        headers: _getAuthHeaders(authToken),
        body: json.encode({'chatRoomId': chatRoomId, 'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Product endpoints
  static Future<bool> createProduct({
    required String title,
    required String description,
    required int price,
    required String categoryId,
    required String location,
    required List<File> images,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/products'),
      );

      // Add text fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['categoryId'] = categoryId;
      request.fields['location'] = location;

      // Add image files
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
          filename: 'image_$i.${file.path.split('.').last}',
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }
}
