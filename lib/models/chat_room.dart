class ChatRoom {
  final String id;
  final int productId;
  final String productTitle;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
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
    required this.sellerId,
    required this.sellerName,
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
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
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
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}