import 'dart:async';
import 'package:olx_clone/models/message.dart';

class SignalRService {
  static const String hubUrl =
      'https://olx-api-production.up.railway.app/chathub';
  bool _isConnected = false;

  Function(Message)? onMessageReceived;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  Future<void> connect() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _isConnected = true;
      onConnected?.call();
    } catch (e) {
      onError?.call('Connection error: $e');
    }
  }

  Future<void> joinChatRoom(String chatRoomId) async {
    try {
      if (_isConnected) {
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        throw Exception('SignalR not connected');
      }
    } catch (e) {
      onError?.call('Error joining room: $e');
    }
  }

  Future<void> leaveChatRoom(String chatRoomId) async {
    try {
      if (_isConnected) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      onError?.call('Error leaving room: $e');
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
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        throw Exception('SignalR not connected');
      }
    } catch (e) {
      onError?.call('Error sending message: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      _isConnected = false;
      onDisconnected?.call();
    } catch (e) {
      // Silent fail
    }
  }

  bool get isConnected => _isConnected;
}
