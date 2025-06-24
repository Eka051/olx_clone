import 'dart:convert';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        userId: json["userId"],
        title: json["title"],
        message: json["message"],
        isRead: json["isRead"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "title": title,
    "message": message,
    "isRead": isRead,
    "createdAt": createdAt.toIso8601String(),
  };
}

NotificationResponse notificationResponseFromJson(String str) =>
    NotificationResponse.fromJson(json.decode(str));

class NotificationResponse {
  final bool success;
  final String message;
  final List<NotificationModel> data;

  NotificationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        success: json["success"],
        message: json["message"],
        data: List<NotificationModel>.from(
          (json["data"] ?? []).map((x) => NotificationModel.fromJson(x)),
        ),
      );
}
