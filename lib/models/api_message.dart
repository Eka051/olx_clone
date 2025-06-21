class ApiMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ApiMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory ApiMessage.fromJson(Map<String, dynamic> json) {
    return ApiMessage(
      id: json['id'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
