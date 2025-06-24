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
    });

    _hubConnection?.onreconnecting(({Exception? error}) {
      _connectionStatusController.add('reconnecting');
    });

    _hubConnection?.onreconnected(({String? connectionId}) {
      _connectionStatusController.add('reconnected');
    });

    _hubConnection?.on('ReceiveMessage', (arguments) {
      try {
        if (arguments != null && arguments.isNotEmpty) {
          final messageJson = arguments[0] as Map<String, dynamic>;
          final message = Message.fromJson(messageJson);
          _messageStreamController.add(message);
        }
      } catch (e) {
        // Error parsing received message
      }
    });

    try {
      await _hubConnection?.start();
      _connectionStatusController.add('connected');
    } catch (e) {
      _connectionStatusController.add('failed');
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      await _hubConnection?.stop();
      _hubConnection = null;
      _connectionStatusController.add('disconnected');
    }
  }

  Future<void> joinRoom(String chatRoomId) async {
    if (!isConnected) return;
    try {
      await _hubConnection?.invoke('JoinRoom', args: [chatRoomId]);
    } catch (e) {
      // Error joining room
    }
  }

  Future<void> leaveRoom(String chatRoomId) async {
    if (!isConnected) return;
    try {
      await _hubConnection?.invoke('LeaveRoom', args: [chatRoomId]);
    } catch (e) {
      // Error leaving room
    }
  }

  Future<void> sendMessageViaSignalR(String chatRoomId, String content) async {
    if (!isConnected) return;
    try {
      await _hubConnection?.invoke('SendMessage', args: [chatRoomId, content]);
    } catch (e) {
      // Error sending message via SignalR
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
        return [];
      }
    } catch (e) {
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
        return [];
      }
    } catch (e) {
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
        return false;
      }
    } catch (e) {
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
        return null;
      }
    } catch (e) {
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
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _messageStreamController.close();
    _connectionStatusController.close();
    stopConnection();
  }
}
