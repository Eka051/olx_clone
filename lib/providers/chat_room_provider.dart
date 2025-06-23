import 'dart:async';
import 'package:flutter/material.dart';
import 'package:olx_clone/models/message.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/services/chat_service.dart';
import 'package:olx_clone/providers/auth_provider.dart';

class ChatRoomProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  ChatRoom? _currentChatRoom;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  final AuthProviderApp _authProvider;
  final ChatService _chatService = ChatService();
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionStatusSubscription;

  ChatRoomProvider(this._authProvider);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChatRoom? get currentChatRoom => _currentChatRoom;
  TextEditingController get messageController => _messageController;
  bool get isConnected => _chatService.isConnected;
  bool get isSending => _isSending;

  Future<void> initializeChatRoom(ChatRoom chatRoom) async {
    _currentChatRoom = chatRoom;
    
    await fetchMessages(chatRoom.id);

    if (!_chatService.isConnected && _authProvider.jwtToken != null) {
      await _chatService.startConnection(_authProvider.jwtToken!);
    }
    
    await _chatService.joinRoom(chatRoom.id);

    _messageSubscription?.cancel();
    _messageSubscription = _chatService.messageStream.listen(_onMessageReceived);

    _connectionStatusSubscription?.cancel();
    _connectionStatusSubscription = _chatService.connectionStatusStream.listen((status) {
      notifyListeners();
    });

  }

  void _onMessageReceived(Message message) {
    if (message.chatRoomId == _currentChatRoom?.id) {
      _messages.add(message);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      markMessagesAsRead();
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String chatRoomId) async {
    if (_authProvider.jwtToken == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await ChatService.getChatRoomMessages(chatRoomId, _authProvider.jwtToken!);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      markMessagesAsRead();
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage() async {
    final token = _authProvider.jwtToken;
    final room = _currentChatRoom;
    if (token == null || room == null) return;

    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    _isSending = true;
    notifyListeners();

    try {
      final success = await ChatService.sendMessage(room.id, content, token);
      if (success) {
        _messageController.clear();
      } else {
        _error = 'Gagal mengirim pesan';
      }
    } catch (e) {
      _error = 'Gagal mengirim pesan: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void markMessagesAsRead() {
    final currentUserId = _authProvider.currentFirebaseUser?.uid;
    if (currentUserId == null) return;
    
    bool hasUnread = false;
    for (var i = 0; i < _messages.length; i++) {
      if (!_messages[i].isRead && _messages[i].senderId != currentUserId) {
        _messages[i] = _messages[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
    }
  }

  void cleanUp() {
    if (_currentChatRoom != null) {
      _chatService.leaveRoom(_currentChatRoom!.id);
    }
    _messageSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
  }

  @override
  void dispose() {
    cleanUp();
    _messageController.dispose();
    super.dispose();
  }
}