import 'dart:async';
import 'package:flutter/material.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/models/message.dart';
import 'package:olx_clone/services/chat_service.dart';
import 'package:olx_clone/providers/chat_filter_provider.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';

class ChatListProvider extends ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;
  final AuthProviderApp _authProvider;
  final ProfileProvider _profileProvider;
  final ChatService _chatService = ChatService();
  StreamSubscription? _messageSubscription;

  ChatListProvider(this._authProvider, this._profileProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;
  int get chatRoomsCount => _chatRooms.length;
  bool get isEmptyButInitialized => _hasInitialized && _chatRooms.isEmpty;

  void _onAuthStateChanged() {
    if (_authProvider.isLoggedIn && _authProvider.jwtToken != null) {
      initializeChatSystem();
    } else {
      disposeChatSystem();
    }
  }

  Future<void> initializeChatSystem() async {
    if (hasInitialized) return;
    await _chatService.startConnection(_authProvider.jwtToken!);
    _messageSubscription = _chatService.messageStream.listen(_handleNewMessage);
    await fetchChatList();
    _hasInitialized = true;
  }

  void disposeChatSystem() {
    _messageSubscription?.cancel();
    _chatService.stopConnection();
    _chatRooms = [];
    _hasInitialized = false;
    notifyListeners();
  }

  String getOtherParticipantName(ChatRoom chatRoom) {
    final currentUserId = _profileProvider.user?.id;
    if (chatRoom.buyerId == currentUserId) {
      return chatRoom.sellerName;
    } else {
      return chatRoom.buyerName;
    }
  }

  List<ChatRoom> getFilteredChatRooms(ChatFilterProvider filterProvider) {
    return filterProvider.getFilteredChats<ChatRoom>(
      _chatRooms,
      getType: (chat) => _determineChatType(chat),
      isImportant: (chat) => chat.unreadCount > 0,
      hasUnread: (chat) => chat.unreadCount > 0,
      getParticipantName: (chat) => getOtherParticipantName(chat),
      getProductTitle: (chat) => chat.productTitle,
    );
  }

  ChatType _determineChatType(ChatRoom chatRoom) {
    final currentUserId = _profileProvider.user?.id;
    if (chatRoom.sellerId == currentUserId) {
      return ChatType.selling;
    }
    return ChatType.buying;
  }

  Future<void> fetchChatList({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    if (forceRefresh) _error = null;
    notifyListeners();

    try {
      if (_authProvider.jwtToken == null) {
        throw Exception('User not authenticated.');
      }

      final chatRoomsData = await ChatService.getChatRooms(
        _authProvider.jwtToken!,
      );
      _chatRooms =
          chatRoomsData.map((data) => ChatRoom.fromJson(data)).toList();
      _chatRooms.sort(
        (a, b) => (b.lastMessageAt ?? b.createdAt).compareTo(
          a.lastMessageAt ?? a.createdAt,
        ),
      );
    } catch (e) {
      _error = e.toString();
      _chatRooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleNewMessage(Message message) {
    final index = _chatRooms.indexWhere(
      (room) => room.id == message.chatRoomId,
    );
    if (index != -1) {
      final room = _chatRooms[index];
      final isCurrentUserSender = message.senderId == _profileProvider.user?.id;

      // Only increment unread count if the message is from the other person.
      final unreadCount =
          isCurrentUserSender ? room.unreadCount : room.unreadCount + 1;

      final updatedRoom = room.copyWith(
        lastMessage: message.content,
        lastMessageAt: message.timestamp,
        unreadCount: unreadCount,
      );

      _chatRooms.removeAt(index);
      _chatRooms.insert(0, updatedRoom);
      notifyListeners();
    } else {
      fetchChatList(forceRefresh: true);
    }
  }

  Future<void> refreshChatList() async {
    await fetchChatList(forceRefresh: true);
  }

  void markAsRead(String chatRoomId) {
    final index = _chatRooms.indexWhere((room) => room.id == chatRoomId);
    if (index != -1 && _chatRooms[index].unreadCount > 0) {
      _chatRooms[index] = _chatRooms[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  int get totalUnreadCount {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    disposeChatSystem();
    super.dispose();
  }
}
