import 'package:flutter/material.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/services/chat_service.dart';
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
      isImportant: (chat) => chat.unreadCount > 0,
      hasUnread: (chat) => chat.unreadCount > 0,
      getParticipantName: (chat) => chat.buyerName,
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
      if (_authProvider.jwtToken == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final chatRoomsData = await ChatService.getChatRooms(
        _authProvider.jwtToken!,
      );
      _chatRooms =
          chatRoomsData.map((data) => ChatRoom.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
      _chatRooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String chatRoomId, String content) async {
    try {
      if (_authProvider.jwtToken == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      return await ChatService.sendMessage(
        chatRoomId,
        content,
        _authProvider.jwtToken!,
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
        buyerId: _chatRooms[index].buyerId,
        buyerName: _chatRooms[index].buyerName,
        sellerId: _chatRooms[index].sellerId,
        sellerName: _chatRooms[index].sellerName,
        createdAt: _chatRooms[index].createdAt,
        lastMessage: message,
        lastMessageAt: timestamp,
        unreadCount: unreadCount,
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
        buyerId: _chatRooms[index].buyerId,
        buyerName: _chatRooms[index].buyerName,
        sellerId: _chatRooms[index].sellerId,
        sellerName: _chatRooms[index].sellerName,
        createdAt: _chatRooms[index].createdAt,
        lastMessage: _chatRooms[index].lastMessage,
        lastMessageAt: _chatRooms[index].lastMessageAt,
        unreadCount: 0,
      );

      _chatRooms[index] = updatedRoom;
      notifyListeners();
    }
  }

  int get totalUnreadCount {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }
}
