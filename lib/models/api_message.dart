class ApiMessage {
  final String id;
  final String content;
  final String senderId;
  final String chatRoomId;
  final bool isRead;
  final DateTime createdAt;

  ApiMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.chatRoomId,
    required this.isRead,
    required this.createdAt,
  });

  factory ApiMessage.fromJson(Map<String, dynamic> json) {
    return ApiMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'chatRoomId': chatRoomId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
