import 'dart:async';
import 'package:olx_clone/models/message.dart';

// Temporary SignalR service implementation
// This will be replaced with actual SignalR package implementation
class SignalRService {
  static const String hubUrl = 'https://olx-api.azurewebsites.net/chathub';
  bool _isConnected = false;

  // Callback functions
  Function(Message)? onMessageReceived;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  Future<void> connect() async {
    try {
      // Simulate connection
      await Future.delayed(const Duration(seconds: 1));
      _isConnected = true;
      onConnected?.call();
      print('SignalR Connected successfully (simulated)');
    } catch (e) {
      print('SignalR Connection error: $e');
      onError?.call('Connection error: $e');
    }
  }

  Future<void> joinChatRoom(String chatRoomId) async {
    try {
      if (_isConnected) {
        // Simulate joining room
        await Future.delayed(const Duration(milliseconds: 500));
        print('Joined chat room: $chatRoomId (simulated)');
      } else {
        throw Exception('SignalR not connected');
      }
    } catch (e) {
      print('Error joining chat room: $e');
      onError?.call('Error joining room: $e');
    }
  }

  Future<void> leaveChatRoom(String chatRoomId) async {
    try {
      if (_isConnected) {
        // Simulate leaving room
        await Future.delayed(const Duration(milliseconds: 300));
        print('Left chat room: $chatRoomId (simulated)');
      }
    } catch (e) {
      print('Error leaving chat room: $e');
    }
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    required String senderId,
    required String senderName,
  }) async {
    try {
      if (_isConnected) {
        // Simulate sending message
        await Future.delayed(const Duration(milliseconds: 200));
        print('Message sent via SignalR (simulated): $content');
      } else {
        throw Exception('SignalR not connected');
      }
    } catch (e) {
      print('Error sending message via SignalR: $e');
      onError?.call('Error sending message: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      _isConnected = false;
      onDisconnected?.call();
      print('SignalR Disconnected (simulated)');
    } catch (e) {
      print('Error disconnecting SignalR: $e');
    }
  }

  bool get isConnected => _isConnected;
}
