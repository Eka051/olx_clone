class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSent;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.isSent = true,
  });
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(
        json['createdAt'] ??
            json['timestamp'] ??
            DateTime.now().toIso8601String(),
      ),
      isRead: json['isRead'] ?? false,
      isSent: json['isSent'] ?? true,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isSent': isSent,
    };
  }

  Message copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSent,
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
    );
  }
}
