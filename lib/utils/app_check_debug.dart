import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class AppCheckDebugHelper {
  static Future<void> printDebugToken() async {
    if (kDebugMode) {
      try {
        final token = await FirebaseAppCheck.instance.getToken(true);
        print('=== Firebase App Check Debug Token ===');
        print('Token: $token');
        print('======================================');
        print('Add this token to Firebase Console:');
        print('1. Go to Firebase Console > Project Settings');
        print('2. Click on App Check tab');
        print('3. Select your Android app');
        print('4. Add this debug token');
        print('======================================');
      } catch (e) {
        print('Error getting App Check token: $e');
      }
    }
  }
}
