import 'package:flutter/material.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/models/api_message.dart';
import 'package:olx_clone/services/api_service.dart';
import 'package:olx_clone/providers/chat_filter_provider.dart';
import 'package:olx_clone/providers/auth_provider.dart';

class ChatListProvider extends ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;
  final AuthProviderApp _authProvider;

  ChatListProvider(this._authProvider);

  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;
  int get chatRoomsCount => _chatRooms.length;
  bool get isEmptyButInitialized => _hasInitialized && _chatRooms.isEmpty;

  List<ChatRoom> getFilteredChatRooms(ChatFilterProvider filterProvider) {
    return filterProvider.getFilteredChats<ChatRoom>(
      _chatRooms,
      getType: (chat) => _determineChatType(chat),
      isImportant:
          (chat) => chat.unreadCount > 0,
      hasUnread: (chat) => chat.unreadCount > 0,
      getParticipantName: (chat) => chat.participantName,
      getProductTitle: (chat) => chat.productTitle,
    );
  }

  ChatType _determineChatType(ChatRoom chatRoom) {
    return chatRoom.id.hashCode % 2 == 0 ? ChatType.buying : ChatType.selling;
  }

  Future<void> initializeChatList() async {
    if (_hasInitialized) return;

    await fetchChatList();
    _hasInitialized = true;
  }

  Future<void> fetchChatList() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_authProvider.backendToken == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final messages = await ApiService.getMessages(_authProvider.backendToken);
      _chatRooms = _convertMessagesToChatRooms(messages);
    } catch (e) {
      _error = e.toString();
      _chatRooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ChatRoom> _convertMessagesToChatRooms(List<ApiMessage> messages) {
    if (messages.isEmpty) return [];

    Map<String, List<ApiMessage>> groupedMessages = {};
    for (var message in messages) {
      if (!groupedMessages.containsKey(message.chatRoomId)) {
        groupedMessages[message.chatRoomId] = [];
      }
      groupedMessages[message.chatRoomId]!.add(message);
    }

    List<ChatRoom> chatRooms = [];
    groupedMessages.forEach((chatRoomId, messageList) {
      messageList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latestMessage = messageList.first;
      final unreadCount = messageList.where((m) => !m.isRead).length;

      chatRooms.add(
        ChatRoom(
          id: chatRoomId,
          productId: 'product_${chatRoomId.substring(0, 8)}',
          productTitle: 'Product Chat',
          productImage: 'assets/images/image-ads.jpg',
          productPrice: 'Rp 0',
          participantId: latestMessage.senderId,
          participantName: 'User ${latestMessage.senderId.substring(0, 8)}',
          participantAvatar: 'assets/images/avatar.png',
          lastMessage: latestMessage.content,
          lastMessageTime: latestMessage.createdAt,
          unreadCount: unreadCount,
          isOnline: false,
        ),
      );
    });

    chatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return chatRooms;
  }

  Future<bool> sendMessage(String chatRoomId, String content) async {
    try {
      if (_authProvider.backendToken == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      return await ApiService.sendMessage(
        chatRoomId: chatRoomId,
        content: content,
        authToken: _authProvider.backendToken,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshChatList() async {
    _hasInitialized = false;
    await fetchChatList();
    _hasInitialized = true;
  }

  void updateLastMessage({
    required String chatRoomId,
    required String message,
    required DateTime timestamp,
    int unreadCount = 0,
  }) {
    final index = _chatRooms.indexWhere((room) => room.id == chatRoomId);
    if (index != -1) {
      final updatedRoom = ChatRoom(
        id: _chatRooms[index].id,
        productId: _chatRooms[index].productId,
        productTitle: _chatRooms[index].productTitle,
        productImage: _chatRooms[index].productImage,
        productPrice: _chatRooms[index].productPrice,
        participantId: _chatRooms[index].participantId,
        participantName: _chatRooms[index].participantName,
        participantAvatar: _chatRooms[index].participantAvatar,
        lastMessage: message,
        lastMessageTime: timestamp,
        unreadCount: unreadCount,
        isOnline: _chatRooms[index].isOnline,
      );

      _chatRooms.removeAt(index);
      _chatRooms.insert(0, updatedRoom);
      notifyListeners();
    }
  }

  void markAsRead(String chatRoomId) {
    final index = _chatRooms.indexWhere((room) => room.id == chatRoomId);
    if (index != -1) {
      final updatedRoom = ChatRoom(
        id: _chatRooms[index].id,
        productId: _chatRooms[index].productId,
        productTitle: _chatRooms[index].productTitle,
        productImage: _chatRooms[index].productImage,
        productPrice: _chatRooms[index].productPrice,
        participantId: _chatRooms[index].participantId,
        participantName: _chatRooms[index].participantName,
        participantAvatar: _chatRooms[index].participantAvatar,
        lastMessage: _chatRooms[index].lastMessage,
        lastMessageTime: _chatRooms[index].lastMessageTime,
        unreadCount: 0,
        isOnline: _chatRooms[index].isOnline,
      );

      _chatRooms[index] = updatedRoom;
      notifyListeners();
    }
  }

  int get totalUnreadCount {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }
}
