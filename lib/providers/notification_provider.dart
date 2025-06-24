import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  String? _token;
  final List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  final String _baseUrl =
      'https://olx-api-production.up.railway.app/api/notifications';

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void updateAuth(AuthProviderApp authProvider) {
    final oldToken = _token;
    _token = authProvider.jwtToken;

    if (oldToken != _token) {
      if (_token != null) {
        fetchNotifications();
      } else {
        _notifications.clear();
        _error = null;
        notifyListeners();
      }
    }
  }

  Future<void> fetchNotifications() async {
    if (_token == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      // debugPrint('NOTIF GET RESPONSE: ' + response.body);
      if (response.statusCode == 200) {
        final notificationResponse = NotificationResponse.fromJson(
          json.decode(response.body),
        );
        debugPrint(
          'NOTIF PARSED: ' + notificationResponse.data.length.toString(),
        );
        if (notificationResponse.success) {
          _notifications
            ..clear()
            ..addAll(notificationResponse.data);
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _error = notificationResponse.message;
        }
      } else {
        final responseData = json.decode(response.body);
        _error =
            responseData['message'] ??
            'Gagal memuat notifikasi: [${response.statusCode}]';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_token == null) return;
    final index = _notifications.indexWhere(
      (notif) => notif.id == notificationId,
    );
    if (index == -1 || _notifications[index].isRead) return;
    final originalIsReadState = _notifications[index].isRead;
    _notifications[index].isRead = true;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode >= 400) {
        _notifications[index].isRead = originalIsReadState;
        notifyListeners();
      }
    } catch (e) {
      _notifications[index].isRead = originalIsReadState;
      notifyListeners();
    }
  }

  void startAutoRefresh({Duration interval = const Duration(minutes: 2)}) {
    Future.doWhile(() async {
      await Future.delayed(interval);
      if (_token != null) await fetchNotifications();
      return _token != null;
    });
  }
}
