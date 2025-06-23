import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/models/message.dart';
import 'package:olx_clone/models/product.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/chat_room_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/utils/theme.dart';

class ChatRoomView extends StatefulWidget {
  final ChatRoom chatRoom;
  final Product? product;

  const ChatRoomView({super.key, required this.chatRoom, this.product});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProviderApp>();
      if (authProvider.jwtToken != null) {
        context.read<ChatRoomProvider>().initializeChatRoom(widget.chatRoom);
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.of(context).colors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).colors.background,
        appBar: _buildAppBar(
          context,
          deviceWidth,
          deviceHeight,
        ),
        body: Consumer<ChatRoomProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              children: [
                _buildProductHeader(context, deviceWidth),
                Expanded(
                  child: _buildMessagesArea(context, chatProvider, deviceWidth),
                ),
                _buildMessageInput(
                  context,
                  chatProvider,
                  deviceWidth,
                  deviceHeight,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    double deviceWidth,
    double deviceHeight,
  ) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentUser = profileProvider.user;

    String otherUserName = "Loading...";
    String? otherUserAvatar;

    if (currentUser != null) {
      if (currentUser.id == widget.chatRoom.buyerId) {
        otherUserName = widget.chatRoom.sellerName;
        otherUserAvatar = widget.chatRoom.sellerProfilePicture;
      } else {
        otherUserName = widget.chatRoom.buyerName;
        otherUserAvatar = widget.chatRoom.buyerProfilePicture;
      }
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(deviceHeight * 0.07),
      child: AppBar(
        backgroundColor: AppTheme.of(context).colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: deviceWidth * 0.05,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: (otherUserAvatar != null &&
                      otherUserAvatar.isNotEmpty)
                  ? NetworkImage(otherUserAvatar)
                  : const AssetImage('assets/images/avatar.png')
                      as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            SizedBox(width: deviceWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    otherUserName,
                    style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: deviceWidth * 0.042,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
          SizedBox(width: deviceWidth * 0.02),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, double deviceWidth) {
    if (widget.product == null) return const SizedBox.shrink();

    final product = widget.product!;

    return Container(
      margin: EdgeInsets.all(deviceWidth * 0.04),
      padding: EdgeInsets.all(deviceWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: deviceWidth * 0.16,
            height: deviceWidth * 0.16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  product.images.isNotEmpty
                      ? Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: deviceWidth * 0.08,
                          );
                        },
                      )
                      : Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: deviceWidth * 0.08,
                      ),
            ),
          ),
          SizedBox(width: deviceWidth * 0.04),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.of(context).colors.primaryTextColor,
                    fontSize: deviceWidth * 0.04,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: deviceWidth * 0.02),
                Text(
                  product.formattedPrice,
                  style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                    color: AppTheme.of(context).colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: deviceWidth * 0.045,
                  ),
                ),
              ],
            ),
          ), // Action Button
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product-details',
                arguments: product,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: deviceWidth * 0.03,
                vertical: deviceWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: AppTheme.of(context).colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Lihat',
                style: AppTheme.of(context).textStyle.bodySmall.copyWith(
                  color: AppTheme.of(context).colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: deviceWidth * 0.032,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(
    BuildContext context,
    ChatRoomProvider chatProvider,
    double deviceWidth,
  ) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.error != null && chatProvider.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Gagal memuat pesan: ${chatProvider.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentUserId = context.watch<ProfileProvider>().user?.id;

    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: deviceWidth * 0.04,
        vertical: 20,
      ),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        final bool isMe = message.senderId == currentUserId;
        return _buildMessageBubble(context, message, isMe, deviceWidth);
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message message,
    bool isMe,
    double deviceWidth,
  ) {
    final theme = AppTheme.of(context);
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? theme.colors.primary : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final timeColor = isMe ? Colors.white70 : Colors.black54;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: deviceWidth * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: theme.textStyle.bodyMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.timestamp.toLocal()),
                  style: theme.textStyle.bodySmall.copyWith(
                    color: timeColor,
                    fontSize: deviceWidth * 0.03,
                  ),
                ),
                if (isMe) SizedBox(width: deviceWidth * 0.01),
                if (isMe)
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    color: message.isRead ? Colors.lightBlueAccent : timeColor,
                    size: deviceWidth * 0.035,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    ChatRoomProvider chatProvider,
    double deviceWidth,
    double deviceHeight,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(deviceWidth * 0.02, deviceWidth * 0.02,
          deviceWidth * 0.02, deviceWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.attach_file,
                color: AppTheme.of(context).colors.secondary,
                size: deviceWidth * 0.06,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: chatProvider.messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.04,
                      vertical: deviceWidth * 0.025,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  onSubmitted: (value) {
                    final message =
                        chatProvider.messageController.text.trim();
                    if (message.isNotEmpty) {
                      chatProvider.sendMessage(message);
                      _scrollToBottom();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: deviceWidth * 0.02),
            InkWell(
              onTap: () {
                final message = chatProvider.messageController.text.trim();
                if (message.isNotEmpty) {
                  chatProvider.sendMessage(message);
                  _scrollToBottom();
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                radius: deviceWidth * 0.06,
                backgroundColor: AppTheme.of(context).colors.primary,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: deviceWidth * 0.055,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
