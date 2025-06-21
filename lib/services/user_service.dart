import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'https://olx-api.azurewebsites.net/api';

  static Future<Map<String, dynamic>?> getUserById(
    String userId,
    String authToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String> getUserName(String userId, String authToken) async {
    try {
      final userData = await getUserById(userId, authToken);
      return userData?['name'] ?? userData?['displayName'] ?? 'Pengguna';
    } catch (e) {
      return 'Pengguna';
    }
  }
}
