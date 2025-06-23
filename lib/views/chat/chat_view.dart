import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/chat_filter_provider.dart';
import 'package:olx_clone/providers/chat_list_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/views/chat/chat_room_view.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ChatListProvider>(
          context,
          listen: false,
        ).initializeChatSystem();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Consumer3<ChatListProvider, ChatFilterProvider, AuthProviderApp>(
      builder: (
        context,
        chatListProvider,
        filterProvider,
        authProvider,
        child,
      ) {
        if (!authProvider.isLoggedIn) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.surface,
              title: const Text('Obrolan'),
              elevation: 0.5,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: colorScheme.onSurface.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  Text('Login Required', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to view your chats',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(120),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: colorScheme.primary,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(deviceHeight * 0.2),
              child: AppBar(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                elevation: 0.5,
                automaticallyImplyLeading: false,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.04,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: deviceHeight * 0.01),
                        SizedBox(
                          height: deviceHeight * 0.05,
                          child: Image.asset(
                            AppAssets.olxBlueLogo,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: deviceHeight * 0.02),
                        Text(
                          'Obrolan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: deviceWidth * 0.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom:
                    _tabController != null
                        ? TabBar(
                          controller: _tabController,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey[600],
                          indicatorWeight: 5.0,
                          labelStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: theme.textTheme.titleSmall,
                          tabs: const [
                            Tab(text: 'SEMUA'),
                            Tab(text: 'MEMBELI'),
                            Tab(text: 'MENJUAL'),
                          ],
                        )
                        : null,
              ),
            ),
            body:
                _tabController != null
                    ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChatListTab(
                          context,
                          chatListProvider,
                          filterProvider,
                          0,
                        ),
                        _buildChatListTab(
                          context,
                          chatListProvider,
                          filterProvider,
                          1,
                        ),
                        _buildChatListTab(
                          context,
                          chatListProvider,
                          filterProvider,
                          2,
                        ),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
          );
      },
    );
  }

  Widget _buildChatListTab(
    BuildContext context,
    ChatListProvider chatListProvider,
    ChatFilterProvider filterProvider,
    int tabIndex,
  ) {
    final currentUserId =
        Provider.of<ProfileProvider>(context, listen: false).user?.id;
    final allChats = chatListProvider.getFilteredChatRooms(filterProvider);
    List<ChatRoom> filteredChats;
    if (tabIndex == 1) {
      filteredChats =
          allChats.where((chat) => chat.buyerId == currentUserId).toList();
    } else if (tabIndex == 2) {
      filteredChats =
          allChats.where((chat) => chat.sellerId == currentUserId).toList();
    } else {
      filteredChats = allChats;
    }
    return _buildChatListCustom(context, filteredChats, chatListProvider);
  }

  Widget _buildChatListCustom(
    BuildContext context,
    List<ChatRoom> chatRooms,
    ChatListProvider chatListProvider,
  ) {
    if (chatListProvider.isLoading && !chatListProvider.hasInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chatListProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Obrolan',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tampaknya ada masalah di server kami. Silakan coba lagi nanti.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => chatListProvider.refreshChatList(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada chat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => chatListProvider.refreshChatList(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          return _buildChatItem(context, chatRoom, chatListProvider);
        },
      ));
  }

  Widget _buildChatItem(
    BuildContext context,
    ChatRoom chatRoom,
    ChatListProvider chatListProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        if (chatRoom.unreadCount > 0) {
          chatListProvider.markAsRead(chatRoom.id);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomView(chatRoom: chatRoom),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceContainer,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (chatRoom.productImageUrl != null && chatRoom.productImageUrl!.isNotEmpty)
                    ? Image.network(
                        chatRoom.productImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceContainer,
                            child: Icon(
                              Icons.image_outlined,
                              color: colorScheme.onSurfaceVariant.withAlpha(100),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/image-ads.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceContainer,
                            child: Icon(
                              Icons.image_outlined,
                              color: colorScheme.onSurfaceVariant.withAlpha(100),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainer,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person_outline,
                                size: 16,
                                color: colorScheme.onSurfaceVariant.withAlpha(
                                  150,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatListProvider.getOtherParticipantName(chatRoom),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.productTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(200),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (chatRoom.lastMessageAt != null)
                        Text(
                          _formatTime(chatRoom.lastMessageAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (chatRoom.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    chatRoom.unreadCount > 9 ? '9+' : '${chatRoom.unreadCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}j';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
