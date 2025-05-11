import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? errorMessage;
  User? user;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        _isLoggedIn = false;
      } else {
        _isLoggedIn = true;
        this.user = user;
      }
      notifyListeners();
    });
  }

  Future<void> getLoginStatus() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = _firebaseAuth.currentUser;
      _isLoggedIn = user != null;

      if (!isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      }
    } catch (e) {
      errorMessage = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(PhoneAuthCredential) verificationCompleted,
    Function(FirebaseAuthException) verificationFailed,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
  ) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmailPassword(String email, String password) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      _isLoggedIn = user != null;

      if (_isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      return _isLoggedIn;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = e.message;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmailPassword(String email, String password) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      _isLoggedIn = user != null;

      if (_isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      return _isLoggedIn;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      user = userCredential.user;
      _isLoggedIn = user != null;

      if (_isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      return _isLoggedIn;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
