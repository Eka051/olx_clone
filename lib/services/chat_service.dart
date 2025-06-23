import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/models/message.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();
  final String baseUrl = "https://olx-api-production.up.railway.app";

  HubConnection? _hubConnection;
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  final StreamController<Message> _messageStreamController =
      StreamController<Message>.broadcast();
  Stream<Message> get messageStream => _messageStreamController.stream;
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;
  Future<void> startConnection(String authToken) async {
    if (isConnected) return;

    _hubConnection =
        HubConnectionBuilder()
            .withUrl('$baseUrl/chathub?access_token=$authToken')
            .withAutomaticReconnect()
            .build();

    _hubConnection?.onclose(({Exception? error}) {
      _connectionStatusController.add('disconnected');
      debugPrint('SignalR Connection Closed: $error');
    });

    _hubConnection?.onreconnecting(({Exception? error}) {
      _connectionStatusController.add('reconnecting');
      debugPrint('SignalR Reconnecting: $error');
    });

    _hubConnection?.onreconnected(({String? connectionId}) {
      _connectionStatusController.add('reconnected');
      debugPrint('SignalR Reconnected: $connectionId');
    });

    _hubConnection?.on('ReceiveMessage', (arguments) {
      try {
        if (arguments != null && arguments.isNotEmpty) {
          final messageJson = arguments[0] as Map<String, dynamic>;
          final message = Message.fromJson(messageJson);
          _messageStreamController.add(message);
        }
      } catch (e) {
        debugPrint('Error parsing received message: $e');
      }
    });

    try {
      await _hubConnection?.start();
      _connectionStatusController.add('connected');
      debugPrint('SignalR Connection Started');
    } catch (e) {
      _connectionStatusController.add('failed');
      debugPrint('Error starting SignalR connection: $e');
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      await _hubConnection?.stop();
      _hubConnection = null;
      _connectionStatusController.add('disconnected');
      debugPrint('SignalR Connection Stopped');
    }
  }

  Future<void> joinRoom(String chatRoomId) async {
    if (!isConnected) return;
    try {
      await _hubConnection?.invoke('JoinRoom', args: [chatRoomId]);
      debugPrint('Joined chat room: $chatRoomId');
    } catch (e) {
      debugPrint('Error joining room $chatRoomId: $e');
    }
  }

  Future<void> leaveRoom(String chatRoomId) async {
    if (!isConnected) return;
    try {
      await _hubConnection?.invoke('LeaveRoom', args: [chatRoomId]);
      debugPrint('Left chat room: $chatRoomId');
    } catch (e) {
      debugPrint('Error leaving room $chatRoomId: $e');
    }
  }

  Future<void> sendMessageViaSignalR(String chatRoomId, String content) async {
    if (!isConnected) return;
    try {
      await _hubConnection?.invoke('SendMessage', args: [chatRoomId, content]);
      debugPrint('Message sent via SignalR to room: $chatRoomId');
    } catch (e) {
      debugPrint('Error sending message via SignalR: $e');
    }
  }

  static Future<List<dynamic>> getChatRooms(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://olx-api-production.up.railway.app/api/chatRooms'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        debugPrint('Failed to get chat rooms: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting chat rooms: $e');
      return [];
    }
  }

  static Future<List<Message>> getChatRoomMessages(
    String chatRoomId,
    String authToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://olx-api-production.up.railway.app/api/chatRooms/$chatRoomId/messages',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages =
            (data['data'] as List)
                .map((msgJson) => Message.fromJson(msgJson))
                .toList();
        return messages;
      } else {
        debugPrint('Failed to get messages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  static Future<bool> sendMessage(
    String chatRoomId,
    String content,
    String authToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://olx-api-production.up.railway.app/api/messages'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'chatRoomId': chatRoomId, 'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to send message: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }
  static Future<ChatRoom?> createChatRoom({
    required String productId,
    required String sellerId,
    required String authToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://olx-api-production.up.railway.app/api/chatRooms'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'productId': productId, 'sellerId': sellerId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatRoom.fromJson(data['data']);
      } else {
        debugPrint('Failed to create chat room: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      return null;
    }
  }

  // Delete chat room
  static Future<bool> deleteChatRoom(
    String chatRoomId,
    String authToken,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(
          'https://olx-api-production.up.railway.app/api/chatRooms/$chatRoomId',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        debugPrint('Failed to delete chat room: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting chat room: $e');
      return false;
    }
  }

  void dispose() {
    _messageStreamController.close();
    _connectionStatusController.close();
    stopConnection();
  }
}
