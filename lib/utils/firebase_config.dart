import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const bool enableAppCheck = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;

  static const Duration authStateCacheTime = Duration(minutes: 5);
  static const Duration tokenCacheTime = Duration(minutes: 10);

  static bool get isDebug => kDebugMode;
  static bool get isProduction => !kDebugMode;
  static Future<void> configureFirebase() async {
    if (enableAppCheck) {
      if (isDebug) {
        await _configureAppCheckForDevelopment();
      } else {
        await _configureAppCheckForProduction();
      }
    }

    await _configureAuthForDevelopment();
  }

  static Future<void> _configureAppCheckForDevelopment() async {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (isDebug) {
        await _printDebugToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase App Check activation error: $e');
      }
    }
  }

  static Future<void> _configureAppCheckForProduction() async {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase App Check activation error: $e');
      }
    }
  }

  static Future<void> _printDebugToken() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final token = await FirebaseAppCheck.instance.getToken(false);
      if (kDebugMode) {
        print('=== Firebase App Check Debug Token ===');
        print('Token: $token');
        print('======================================');
        print('Register this token in Firebase Console:');
        print('1. Go to Firebase Console > Project Settings');
        print('2. Click App Check tab');
        print('3. Select your Android app');
        print('4. Add this debug token');
        print('======================================');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting App Check token: $e');
        print('SOLUTION: Disable App Check enforcement in Firebase Console');
        print('Go to Firebase Console > Authentication > Settings > App Check');
        print('Turn OFF enforcement for Phone Authentication temporarily');
      }
    }
  }

  static Future<void> _configureAuthForDevelopment() async {
    try {
      final auth = FirebaseAuth.instance;

      await auth.setSettings(
        appVerificationDisabledForTesting: false,
        userAccessGroup: null,
      );

      auth.setLanguageCode('id');
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Auth configuration error: $e');
      }
    }
  }
}
