import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? errorMessage;
  User? user;
  bool _isPhoneValid = false;
  bool _isEmailValid = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isPhoneValid => _isPhoneValid;
  bool get isEmailValid => _isEmailValid;

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

    phoneNumberController.addListener(_validatePhoneNumber);
  }

  void _validatePhoneNumber() {
    final text = phoneNumberController.text;
    final isValid =
        text.length >= 10 &&
        !text.startsWith('0') &&
        RegExp(r'^[1-9]\d*$').hasMatch(text);
    if (isValid != _isPhoneValid) {
      _isPhoneValid = isValid;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneNumberController.removeListener(_validatePhoneNumber);
    phoneNumberController.dispose();
    otpController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool validatePhoneNumber(String phoneNumber) {
    errorMessage = null;

    if (phoneNumber.isEmpty) {
      errorMessage = 'Nomor telepon tidak boleh kosong';
      return false;
    }
    if (phoneNumber.length < 10) {
      errorMessage = 'Nomor telepon kurang dari 10 digit';
      return false;
    }
    if (!RegExp(r'^[1-9]\d*$').hasMatch(phoneNumber)) {
      errorMessage = 'Format tidak valid';
      return false;
    }
    notifyListeners();
    return true;
  }

  bool validateOTP(String otp) {
    errorMessage = null;

    if (otp.isEmpty) {
      errorMessage = 'Kode OTP tidak boleh kosong';
      return false;
    }
    if (otp.length < 6) {
      errorMessage = 'Kode OTP kurang dari 6 digit';
      return false;
    }
    notifyListeners();
    return true;
  }

  bool validateEmail(String email) {
    errorMessage = null;

    if (email.isEmpty) {
      errorMessage = 'Email tidak boleh kosong';
      return false;
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      errorMessage = 'Format email tidak valid';
      return false;
    }
    notifyListeners();
    return true;
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
      debugPrint('Error verifying phone number: $errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(
    String verificationId, {
    required String smsCode,
  }) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      user = userCredential.user;
      _isLoggedIn = user != null;

      if (_isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      return _isLoggedIn;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Kode OTP tidak valid. Silakan coba lagi.';
      } else if (e.code == 'invalid-verification-id') {
        errorMessage =
            'Sesi verifikasi telah berakhir. Silakan kirim ulang kode.';
      } else {
        errorMessage = 'Verifikasi gagal: ${e.message}';
      }
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendOTP(String formattedPhoneNumber) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // This function now expects the phone number to be already formatted with +62
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber:
            formattedPhoneNumber, // Use the formatted phone number directly
        verificationCompleted: (PhoneAuthCredential credential) async {
          await signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage = e.message;
        },
        codeSent: (String newVerificationId, int? resendToken) {
          // Success - just need to return true
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {
          // Timeout handling
        },
        timeout: const Duration(seconds: 60),
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(String email) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://your-app-url.com',
          handleCodeInApp: true,
          androidPackageName: 'com.example.olx_clone',
          androidInstallApp: true,
          androidMinimumVersion: '21',
        ),
      );

      errorMessage = 'Verification email sent. Please check your inbox.';
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
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

  Future<bool> verifyCodeEmail(String email, String code) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: code,
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

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
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

  Future<bool> signInWithCredential(PhoneAuthCredential credential) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
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
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> handleOTPVerification(
    String verificationId,
    String smsCode,
    BuildContext context,
  ) async {
    final success = await verifyOTP(verificationId, smsCode: smsCode);

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }

    return success;
  }
}
