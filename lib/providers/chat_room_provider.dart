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
  bool _isConnected = false;
  bool _isSending = false;
  final AuthProviderApp _authProvider;

  ChatRoomProvider(this._authProvider);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChatRoom? get currentChatRoom => _currentChatRoom;
  TextEditingController get messageController => _messageController;
  bool get isConnected => _isConnected;
  bool get isSending => _isSending;
  Future<void> initializeChatRoom(ChatRoom chatRoom, String authToken) async {
    _currentChatRoom = chatRoom;
    await fetchMessages(chatRoom.id, authToken);
  }

  Future<void> fetchMessages(String chatRoomId, String authToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await ChatService.getChatRoomMessages(chatRoomId, authToken);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage() async {
    if (_authProvider.jwtToken == null || _currentChatRoom == null) return;

    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    _isSending = true;
    notifyListeners();

    try {
      final success = await ChatService.sendMessage(
        _currentChatRoom!.id,
        content,
        _authProvider.jwtToken!,
      );

      if (success) {
        _messageController.clear();
        await fetchMessages(_currentChatRoom!.id, _authProvider.jwtToken!);
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

  void markMessagesAsRead(String currentUserId) {
    bool hasUnreadMessages = false;
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isRead && _messages[i].senderId != currentUserId) {
        _messages[i] = _messages[i].copyWith(isRead: true);
        hasUnreadMessages = true;
      }
    }
    if (hasUnreadMessages) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
