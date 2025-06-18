import 'package:flutter/material.dart';
import 'package:olx_clone/models/message.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/services/signalr_service.dart';

class ChatRoomProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  ChatRoom? _currentChatRoom;
  final TextEditingController _messageController = TextEditingController();
  final SignalRService _signalRService = SignalRService();
  bool _isConnected = false;
  bool _isSending = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChatRoom? get currentChatRoom => _currentChatRoom;
  TextEditingController get messageController => _messageController;
  bool get isConnected => _isConnected;
  bool get isSending => _isSending;

  // Mock current user ID
  final String _currentUserId = 'current_user_123';
  final String _currentUserName = 'Current User';

  // Mock messages untuk demonstrasi
  List<Message> _getMockMessages(String chatRoomId) {
    return [
      Message(
        id: '1',
        chatRoomId: chatRoomId,
        senderId: 'other_user',
        senderName: 'Ahmad Rizki',
        content: 'Halo, saya tertarik dengan barang yang Anda jual',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Message(
        id: '2',
        chatRoomId: chatRoomId,
        senderId: _currentUserId,
        senderName: _currentUserName,
        content: 'Halo juga! Silakan, barang masih tersedia',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 58),
        ),
        isRead: true,
      ),
      Message(
        id: '3',
        chatRoomId: chatRoomId,
        senderId: 'other_user',
        senderName: 'Ahmad Rizki',
        content: 'Kondisinya masih bagus kan? Bisa nego harganya?',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 55),
        ),
        isRead: true,
      ),
      Message(
        id: '4',
        chatRoomId: chatRoomId,
        senderId: _currentUserId,
        senderName: _currentUserName,
        content:
            'Kondisi masih sangat bagus, baru pakai 6 bulan. Untuk harga bisa sedikit nego 😊',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 50),
        ),
        isRead: true,
      ),
      Message(
        id: '5',
        chatRoomId: chatRoomId,
        senderId: 'other_user',
        senderName: 'Ahmad Rizki',
        content: 'Kalau 16 juta gimana? Saya serius nih',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      Message(
        id: '6',
        chatRoomId: chatRoomId,
        senderId: _currentUserId,
        senderName: _currentUserName,
        content: 'Hmm, gimana ya... 17 juta deh, udah net. Gimana?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: true,
      ),
      Message(
        id: '7',
        chatRoomId: chatRoomId,
        senderId: 'other_user',
        senderName: 'Ahmad Rizki',
        content: 'Deal! Kapan bisa COD?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
    ];
  }

  Future<void> initializeChatRoom(ChatRoom chatRoom) async {
    _currentChatRoom = chatRoom;
    await _setupSignalR(chatRoom.id);
    await fetchMessages(chatRoom.id);
  }

  Future<void> fetchMessages(String chatRoomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Untuk sementara menggunakan mock data
      // Nanti bisa diganti dengan: final messages = await ApiService.getChatMessages(chatRoomId);
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network delay
      _messages = _getMockMessages(chatRoomId);

      // Sort messages by timestamp (oldest first for chat display)
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      _error = e.toString();
      _messages = _getMockMessages(chatRoomId); // Fallback to mock data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending || _currentChatRoom == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final tempMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        chatRoomId: _currentChatRoom!.id,
        senderId: _currentUserId,
        senderName: _currentUserName,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        isSent: false, // Will be updated when confirmed
      );

      // Optimistic update - add message immediately to UI
      _messages.add(tempMessage);
      _messageController.clear();
      notifyListeners();

      // Send via SignalR
      await _signalRService.sendMessage(
        chatRoomId: _currentChatRoom!.id,
        content: content,
        senderId: _currentUserId,
        senderName: _currentUserName,
      );

      // Simulate server response
      await Future.delayed(const Duration(milliseconds: 500));

      // Update message as sent
      final index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = tempMessage.copyWith(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          isSent: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal mengirim pesan: $e';
      // Remove the failed message
      _messages.removeWhere((msg) => msg.id.startsWith('temp_'));
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> _setupSignalR(String chatRoomId) async {
    _signalRService.onMessageReceived = (message) {
      // Only add if it's not from current user
      if (message.senderId != _currentUserId) {
        _messages.add(message);
        notifyListeners();
      }
    };

    _signalRService.onConnected = () {
      _isConnected = true;
      notifyListeners();
    };

    _signalRService.onDisconnected = () {
      _isConnected = false;
      notifyListeners();
    };

    _signalRService.onError = (error) {
      _error = error;
      notifyListeners();
    };

    await _signalRService.connect();
    await _signalRService.joinChatRoom(chatRoomId);
  }

  void markMessagesAsRead() {
    bool hasUnreadMessages = false;
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isRead && _messages[i].senderId != _currentUserId) {
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
    _signalRService.disconnect();
    super.dispose();
  }
}
