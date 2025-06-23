class ChatRoom {
  final String id;
  final int productId;
  final String productTitle;
  final String buyerId;
  final String buyerName;
  final String? buyerProfilePictureUrl;
  final String sellerId;
  final String sellerName;
  final String? sellerProfilePictureUrl;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.buyerId,
    required this.buyerName,
    this.buyerProfilePictureUrl,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfilePictureUrl,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      productId: json['productId'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerProfilePictureUrl: json['buyerProfilePictureUrl'],
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerProfilePictureUrl: json['sellerProfilePictureUrl'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productTitle': productTitle,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerProfilePictureUrl': buyerProfilePictureUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerProfilePictureUrl': sellerProfilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  ChatRoom copyWith({
    String? id,
    int? productId,
    String? productTitle,
    String? buyerId,
    String? buyerName,
    String? buyerProfilePictureUrl,
    String? sellerId,
    String? sellerName,
    String? sellerProfilePictureUrl,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerProfilePictureUrl: buyerProfilePictureUrl ?? this.buyerProfilePictureUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerProfilePictureUrl: sellerProfilePictureUrl ?? this.sellerProfilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
