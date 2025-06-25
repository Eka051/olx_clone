import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviderApp with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? errorMessage;
  String? successMessage;
  User? _firebaseUser;
  bool _isPhoneValid = false;
  bool _isEmailValid = false;
  bool _isVerifying = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  String? _currentVerificationId;
  String? _currentOtpType;
  String? _currentPhoneNumber;
  String? _currentEmail;

  final String _backendUrl = 'https://olx-api-production.up.railway.app';
  String? _jwtToken;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isPhoneValid => _isPhoneValid;
  bool get isEmailValid => _isEmailValid;
  bool get isVerifying => _isVerifying;
  String? get jwtToken => _jwtToken;
  User? get currentFirebaseUser => _firebaseUser;

  AuthProviderApp() {
    _firebaseAuth.authStateChanges().listen((User? fbUser) {
      _firebaseUser = fbUser;
      if (_jwtToken == null && _isLoggedIn) {
        _isLoggedIn = false;
      }
      notifyListeners();
    });

    phoneNumberController.addListener(_validatePhoneNumber);
    emailController.addListener(_validateEmail);
    getLoginStatus();
  }

  void _validateEmail() {
    validateEmail(emailController.text);
  }

  void _validatePhoneNumber() {
    validatePhoneNumber(phoneNumberController.text);
  }

  Future<void> _saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setBool('isLoggedIn', true);
    _jwtToken = token;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> _clearJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.setBool('isLoggedIn', false);
    _jwtToken = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> getLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _jwtToken = prefs.getString('jwt_token');
      _isLoggedIn = _jwtToken != null && _jwtToken!.isNotEmpty;
      _firebaseUser = _firebaseAuth.currentUser;
    } catch (e) {
      errorMessage = "Gagal memuat status login: ${e.toString()}";
      _isLoggedIn = false;
      _jwtToken = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setupOtpSession({
    String? phoneNumber,
    String? email,
    String? verificationId,
    required String type,
  }) {
    _currentPhoneNumber = phoneNumber;
    _currentEmail = email;
    _currentVerificationId = verificationId;
    _currentOtpType = type;
    clearOtpFields();
    notifyListeners();
  }
  
  void handleOtpInputChange(BuildContext context) {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == 6 &&
        !otpControllers.any((c) => c.text.isEmpty) &&
        !isVerifying) {
    }
  }
  
  Future<void> submitOtp(BuildContext context) async {
    if (_isVerifying) return;
    
    _isVerifying = true;
    notifyListeners();

    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
        _showSnackBar(context, "Harap isi 6 digit OTP dengan lengkap.", Colors.red);
        _isVerifying = false;
        notifyListeners();
        return;
    }
    
    bool success = false;
    String finalErrorMessage = 'Kode OTP tidak valid atau terjadi kesalahan.';

    try {
      if (_currentOtpType == 'phone' && _currentVerificationId != null) {
        success = await _verifyPhoneOtpAndLogin(otp);
        if (!success) finalErrorMessage = errorMessage ?? finalErrorMessage;
      } else if (_currentOtpType == 'email' && _currentEmail != null) {
        success = await verifyCodeEmail(_currentEmail!, otp);
        if (!success) finalErrorMessage = errorMessage ?? finalErrorMessage;
      }

      if (success && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else if (context.mounted) {
        _showSnackBar(context, finalErrorMessage, Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Terjadi kesalahan: ${e.toString()}', Colors.red);
      }
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }
  
  Future<bool> _verifyPhoneOtpAndLogin(String otp) async {
      try {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _currentVerificationId!,
          smsCode: otp,
        );
        UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        _firebaseUser = userCredential.user;

        if (_firebaseUser != null) {
          final String? firebaseIdToken = await _firebaseUser!.getIdToken(true);
          if (firebaseIdToken != null) {
            return await _sendFirebaseTokenToBackend(firebaseIdToken);
          } else {
            errorMessage = "Gagal mendapatkan token Firebase setelah verifikasi OTP.";
            return false;
          }
        } else {
          errorMessage = "Gagal login ke Firebase dengan OTP.";
          return false;
        }
      } catch (e) {
        errorMessage = "Error verifikasi OTP telepon: ${e.toString()}";
        return false;
      }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String getOtpDisplayTarget() {
    return _currentOtpType == 'phone' ? _currentPhoneNumber ?? '' : _currentEmail ?? '';
  }

  String getResendButtonText() {
    return _currentOtpType == 'phone'
        ? 'Kirim ulang kode OTP ke nomor ${getOtpDisplayTarget()}'
        : 'Kirim ulang kode OTP ke email ${getOtpDisplayTarget()}';
  }

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

  Future<void> handleResendOtp(BuildContext context) async {
    if (_currentOtpType == 'phone' && _currentPhoneNumber != null) {
      await verifyPhoneNumberWithDialog(context, _currentPhoneNumber!, '/otp_phone_screen_route');
    } else if (_currentOtpType == 'email' && _currentEmail != null) {
      bool sent = await requestEmailOtp(_currentEmail!);
      if (sent && context.mounted) {
        _showSnackBar(context, successMessage ?? 'Kode OTP telah dikirim ulang.', Colors.green);
      } else if (context.mounted) {
        _showSnackBar(context, errorMessage ?? 'Gagal mengirim ulang OTP.', Colors.red);
      }
    }
  }

  bool validatePhoneNumber(String phoneNumber) {
    errorMessage = null;
    if (phoneNumber.isEmpty) {
      errorMessage = 'Nomor telepon tidak boleh kosong';
      _isPhoneValid = false;
    } else if (phoneNumber.length < 10) {
      errorMessage = 'Nomor telepon kurang dari 10 digit';
      _isPhoneValid = false;
    } else if (!RegExp(r'^[1-9]\d*$').hasMatch(phoneNumber)) {
      errorMessage = 'Format tidak valid';
      _isPhoneValid = false;
    } else {
      _isPhoneValid = true;
    }
    notifyListeners();
    return _isPhoneValid;
  }

  bool validateEmail(String email) {
    if (email.isEmpty) {
      _isEmailValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _isEmailValid = false;
    } else {
      _isEmailValid = true;
    }
    notifyListeners();
    return _isEmailValid;
  }
  
  Future<bool> _sendFirebaseTokenToBackend(String firebaseIdToken) async {
    final url = Uri.parse('$_backendUrl/api/auth/firebase');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'idToken': firebaseIdToken});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final token = responseData['data']['token'];
        if (token != null) {
          await _saveJwtToken(token);
          return true;
        }
      }
      errorMessage = responseData['message'] ?? 'Gagal otentikasi dengan server.';
      return false;
    } catch (e) {
      errorMessage = 'Error komunikasi backend: ${e.toString()}';
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut().catchError((_) {});
      await _firebaseAuth.signOut().catchError((_) {});

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;

      if (_firebaseUser != null) {
        final String? firebaseIdToken = await _firebaseUser!.getIdToken(true);
        if (firebaseIdToken != null) {
          return await _sendFirebaseTokenToBackend(firebaseIdToken);
        }
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

  Future<void> verifyPhoneNumberForOtp(String rawPhoneNumber, Function(String, String) onCodeSent, Function(String) onError) async {
    String formattedPhoneNumber = '+62$rawPhoneNumber';
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (_) {},
        verificationFailed: (e) => onError(e.message ?? "Verifikasi gagal"),
        codeSent: (verificationId, _) => onCodeSent(verificationId, formattedPhoneNumber),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }
  
  Future<bool> signUpWithEmail(String email) async {
    return await requestEmailOtp(email);
  }

  Future<bool> requestEmailOtp(String email) async {
    _isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    
    final url = Uri.parse('$_backendUrl/api/auth/email/otp');
    final headers = {'Content-Type': 'application/json', 'accept': 'text/plain'};
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        successMessage = responseData['message'] ?? 'Kode OTP berhasil dikirim.';
        setupOtpSession(email: email, type: 'email');
        return true;
      } else {
        errorMessage = responseData['message'] ?? 'Gagal meminta OTP.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Gagal mengirim permintaan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCodeEmail(String email, String code) async {
    final url = Uri.parse('$_backendUrl/api/auth/email/verify');
    final headers = {'Content-Type': 'application/json', 'accept': 'text/plain'};
    final body = jsonEncode({'email': email, 'otp': code});

    try {
        final response = await http.post(url, headers: headers, body: body);
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['success'] == true) {
            final token = responseData['data']?['token'];
            if (token != null) {
                await _saveJwtToken(token);
                successMessage = responseData['message'] ?? 'Verifikasi berhasil.';
                return true;
            } else {
                errorMessage = 'Token tidak ditemukan dalam respons server.';
                return false;
            }
        } else {
            errorMessage = responseData['message'] ?? 'Verifikasi gagal.';
            return false;
        }
    } catch (e) {
        errorMessage = 'Terjadi kesalahan saat verifikasi: ${e.toString()}';
        return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut().catchError((_) {});
      await _firebaseAuth.signOut().catchError((_) {});
      await _clearJwtToken();
    } catch (e) {
      errorMessage = "Gagal logout: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyPhoneNumberWithDialog(BuildContext context, String rawPhoneNumber, String routeName) async {
    _isLoading = true;
    notifyListeners();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    await verifyPhoneNumberForOtp(
      rawPhoneNumber,
      (verificationId, formattedPhoneNumber) {
        if (context.mounted) {
          Navigator.pop(context);
          setupOtpSession(phoneNumber: formattedPhoneNumber, verificationId: verificationId, type: 'phone');
          Navigator.pushNamed(context, routeName);
        }
      },
      (error) {
        if (context.mounted) {
          Navigator.pop(context);
          _showSnackBar(context, error, Colors.red);
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
