import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/providers/chat_room_provider.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/models/chat_room.dart';
import 'package:olx_clone/models/message.dart';
import 'package:olx_clone/models/product.dart';

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
        appBar: _buildAppBar(context, deviceWidth, deviceHeight),
        body: Consumer<ChatRoomProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              children: [
                // Product Info Header
                _buildProductHeader(context, deviceWidth),

                // Messages Area
                Expanded(
                  child: _buildMessagesArea(context, chatProvider, deviceWidth),
                ),

                // Message Input
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
              backgroundImage: AssetImage('assets/images/avatar.png'),
              onBackgroundImageError: (_, __) {},
              child: null,
            ),
            SizedBox(width: deviceWidth * 0.03),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.chatRoom.sellerName,
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
            onPressed: () {
              // Add call functionality
            },
            icon: const Icon(Icons.call, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // Add more options
            },
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
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).colors.primary,
        ),
      );
    }

    if (chatProvider.error != null && chatProvider.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(deviceWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: deviceWidth * 0.15,
                color: Colors.grey[400],
              ),
              SizedBox(height: deviceWidth * 0.04),
              Text(
                'Gagal memuat pesan',
                style: AppTheme.of(context).textStyle.titleMedium.copyWith(
                  color: AppTheme.of(context).colors.primaryTextColor,
                ),
              ),
              SizedBox(height: deviceWidth * 0.02),
              ElevatedButton(
                onPressed: () {
                  final authProvider = context.read<AuthProviderApp>();
                  if (authProvider.jwtToken != null) {
                    chatProvider.fetchMessages(widget.chatRoom.id);
                  }
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: deviceWidth * 0.04,
        vertical: deviceWidth * 0.02,
      ),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        final authProvider = context.read<AuthProviderApp>();
        final isMe =
            message.senderId ==
            (authProvider.currentFirebaseUser?.uid ?? 'current_user');

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
    return Container(
      margin: EdgeInsets.symmetric(vertical: deviceWidth * 0.01),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: deviceWidth * 0.04,
              backgroundColor: Colors.grey[300],
              backgroundImage: AssetImage('assets/images/avatar.png'),
              onBackgroundImageError: (_, __) {},
              child: null,
            ),
            SizedBox(width: deviceWidth * 0.02),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: deviceWidth * 0.75),
              padding: EdgeInsets.symmetric(
                horizontal: deviceWidth * 0.04,
                vertical: deviceWidth * 0.03,
              ),
              decoration: BoxDecoration(
                color:
                    isMe
                        ? AppTheme.of(context).colors.primary
                        : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                      color:
                          isMe
                              ? Colors.white
                              : AppTheme.of(context).colors.primaryTextColor,
                      fontSize: deviceWidth * 0.038,
                    ),
                  ),
                  SizedBox(height: deviceWidth * 0.01),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: AppTheme.of(
                          context,
                        ).textStyle.bodySmall.copyWith(
                          color:
                              isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : AppTheme.of(
                                    context,
                                  ).colors.secondaryTextColor,
                          fontSize: deviceWidth * 0.028,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: deviceWidth * 0.01),
                        Icon(
                          message.isSent
                              ? (message.isRead ? Icons.done_all : Icons.done)
                              : Icons.access_time,
                          size: deviceWidth * 0.035,
                          color:
                              message.isRead
                                  ? Colors.blue[300]
                                  : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: deviceWidth * 0.02),
        ],
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
      padding: EdgeInsets.all(deviceWidth * 0.04),
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
          children: [
            // Attachment button
            Container(
              margin: EdgeInsets.only(right: deviceWidth * 0.02),
              child: IconButton(
                onPressed: () {
                  // Add attachment functionality
                },
                icon: Icon(
                  Icons.attach_file,
                  color: AppTheme.of(context).colors.secondary,
                  size: deviceWidth * 0.06,
                ),
              ),
            ),

            // Text input
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
                    hintStyle: AppTheme.of(
                      context,
                    ).textStyle.bodyMedium.copyWith(
                      color: AppTheme.of(context).colors.hintTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.04,
                      vertical: deviceWidth * 0.03,
                    ),
                  ),
                  style: AppTheme.of(
                    context,
                  ).textStyle.bodyMedium.copyWith(fontSize: deviceWidth * 0.04),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) {
                    chatProvider.sendMessage();
                    _scrollToBottom();
                  },
                ),
              ),
            ),

            // Send button
            Container(
              margin: EdgeInsets.only(left: deviceWidth * 0.02),
              child:
                  chatProvider.isSending
                      ? SizedBox(
                        width: deviceWidth * 0.06,
                        height: deviceWidth * 0.06,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.of(context).colors.primary,
                        ),
                      )
                      : IconButton(
                        onPressed: () {
                          chatProvider.sendMessage();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                        },
                        icon: Container(
                          padding: EdgeInsets.all(deviceWidth * 0.025),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: deviceWidth * 0.05,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time only
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Kemarin ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Other days - show date and time
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
