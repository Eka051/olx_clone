import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/message.dart';

class ChatService {
  static const String baseUrl = 'https://olx-api.azurewebsites.net/api';

  static Future<List<Message>> getChatRoomMessages(
    String chatRoomId,
    String authToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chatRooms/$chatRoomId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> messagesJson = jsonData['data'];
          return messagesJson.map((json) => Message.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createChatRoom(
    int productId,
    String initialMessage,
    String authToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatRooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'productId': productId,
          'initialMessage': initialMessage,
        }),
      );

      if (response.statusCode == 201) {
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

  static Future<bool> sendMessage(
    String chatRoomId,
    String content,
    String authToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatRooms/$chatRoomId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'content': content}),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteChatRoom(
    String chatRoomId,
    String authToken,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chatRooms/$chatRoomId'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getChatRooms(
    String authToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chatRooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return List<Map<String, dynamic>>.from(jsonData['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
