import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  String? _currentVerificationId;
  String? _currentOtpType;
  String? _currentPhoneNumber;
  String? _currentEmail;
  final String _backendUrl = 'https://olx-api-production.up.railway.app';
  String? _jwtToken;

  DateTime? _lastTokenRequest;
  static const Duration _tokenRequestCooldown = Duration(seconds: 30);

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isPhoneValid => _isPhoneValid;
  bool get isEmailValid => _isEmailValid;
  bool get isVerifying => _isVerifying;
  String? get jwtToken => _jwtToken;
  User? get currentFirebaseUser => _firebaseUser;
  AuthProviderApp() {
    _firebaseAuth.authStateChanges().distinct().listen((User? fbUser) {
      if (_firebaseUser?.uid != fbUser?.uid) {
        _firebaseUser = fbUser;
        if (_jwtToken == null && _isLoggedIn) {
          _isLoggedIn = false;
        }
        notifyListeners();
      }
    });

    phoneNumberController.addListener(_validatePhoneNumber);
    emailController.addListener(_validateEmail);
    getLoginStatus();
  }

  void _validateEmail() {
    validateEmail(emailController.text);
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

  Future<void> _saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setBool('isLoggedIn', true);
    _jwtToken = token;
    _isLoggedIn = true;
    _firebaseUser = _firebaseAuth.currentUser;
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
    errorMessage = null;
    successMessage = null;
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

  void handleOtpInputChange(BuildContext context) {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == 6 &&
        !otpControllers.any((c) => c.text.isEmpty) &&
        !isVerifying) {
      _autoVerifyOtp(context, otp);
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

  Future<void> _autoVerifyOtp(BuildContext context, String otp) async {
    _isVerifying = true;
    notifyListeners();
    bool success = false;
    String finalErrorMessage = 'Kode OTP tidak valid atau terjadi kesalahan.';

    try {
      if (_currentOtpType == 'phone' && _currentVerificationId != null) {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _currentVerificationId!,
          smsCode: otp,
        );
        UserCredential userCredential = await _firebaseAuth
            .signInWithCredential(credential);
        _firebaseUser = userCredential.user;
        if (_firebaseUser != null) {
          final String? firebaseIdToken = await _getFirebaseTokenSafely();
          if (firebaseIdToken != null) {
            success = await _sendFirebaseTokenToBackend(firebaseIdToken);
            if (!success) finalErrorMessage = errorMessage ?? finalErrorMessage;
          } else {
            finalErrorMessage =
                errorMessage ?? "Gagal mendapatkan token Firebase.";
            success = false;
          }
        } else {
          finalErrorMessage = "Gagal login ke Firebase.";
          success = false;
        }
      } else if (_currentOtpType == 'email' && _currentEmail != null) {
        success = await verifyCodeEmail(_currentEmail!, otp);
        if (!success) finalErrorMessage = errorMessage ?? finalErrorMessage;
      }

      if (success && context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      } else if (context.mounted) {
        clearOtpFields();
        _showSnackBar(context, finalErrorMessage, Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        clearOtpFields();
        _showSnackBar(
          context,
          'Terjadi kesalahan: ${e.toString()}',
          Colors.red,
        );
      }
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String getOtpDisplayTarget() {
    return _currentOtpType == 'phone'
        ? _currentPhoneNumber ?? ''
        : _currentEmail ?? '';
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
    notifyListeners();
  }

  Future<void> handleResendOtp(BuildContext context) async {
    if (_currentOtpType == 'phone' && _currentPhoneNumber != null) {
      await verifyPhoneNumberWithDialog(
        context,
        _currentPhoneNumber!,
        '/otp_phone_screen_route',
      );
    } else if (_currentOtpType == 'email' && _currentEmail != null) {
      bool sent = await signUpWithEmail(_currentEmail!);
      if (sent && context.mounted) {
        _showSnackBar(
          context,
          successMessage ?? 'Kode OTP telah dikirim ulang.',
          Colors.green,
        );
      } else if (context.mounted) {
        _showSnackBar(
          context,
          errorMessage ?? 'Gagal mengirim ulang OTP.',
          Colors.red,
        );
      }
    }
  }

  @override
  void dispose() {
    phoneNumberController.removeListener(_validatePhoneNumber);
    phoneNumberController.dispose();
    emailController.removeListener(_validateEmail);
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
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

  bool validateEmail(String email) {
    errorMessage = null;
    if (email.isEmpty) {
      errorMessage = 'Email tidak boleh kosong';
      _isEmailValid = false;
      notifyListeners();
      return false;
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      errorMessage = 'Format email tidak valid';
      _isEmailValid = false;
      notifyListeners();
      return false;
    }
    _isEmailValid = true;
    notifyListeners();
    return true;
  }

  Future<bool> _sendFirebaseTokenToBackend(String firebaseIdToken) async {
    final url = Uri.parse('$_backendUrl/api/auth/firebase');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'idToken': firebaseIdToken});
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) {
        errorMessage = 'Server mengembalikan respons kosong.';
        successMessage = null;
        return false;
      }

      final Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        errorMessage = 'Respons server tidak valid: ${e.toString()}';
        successMessage = null;
        return false;
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        if (data != null && data['token'] != null) {
          await _saveJwtToken(data['token']);
          successMessage = data['message'] ?? 'Login berhasil.';
          errorMessage = null;
          return true;
        } else {
          errorMessage = 'Token tidak ditemukan dalam respons backend.';
          successMessage = null;
          return false;
        }
      } else {
        final message = responseData['message'] ?? 'Gagal login ke backend.';
        errorMessage = 'Backend Error (${response.statusCode}): $message';
        successMessage = null;
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'Koneksi ke server timeout. Periksa koneksi internet Anda.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else {
        errorMessage = 'Error komunikasi backend: ${e.toString()}';
      }
      successMessage = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
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
      _firebaseUser = userCredential.user;

      if (_firebaseUser != null) {
        final String? firebaseIdToken = await _getFirebaseTokenSafely();
        if (firebaseIdToken != null) {
          bool backendSuccess = await _sendFirebaseTokenToBackend(
            firebaseIdToken,
          );
          if (backendSuccess) {
            return true;
          } else {
            errorMessage =
                errorMessage ??
                "Login Firebase berhasil, tapi gagal koneksi ke server.";
            return false;
          }
        } else {
          errorMessage = errorMessage ?? "Gagal mendapatkan token Firebase.";
          return false;
        }
      } else {
        errorMessage = "Gagal login ke Firebase.";
        return false;
      }
    } catch (e) {
      errorMessage = "Error saat login dengan Google: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyPhoneNumberForOtp(
    String rawPhoneNumber,
    Function(String verificationId, String formattedPhoneNumber) onCodeSent,
    Function(String error) onError,
  ) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    String formattedPhoneNumber = '+62$rawPhoneNumber';

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          errorMessage = e.message ?? "Verifikasi nomor telepon gagal.";
          onError(errorMessage!);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, formattedPhoneNumber);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      errorMessage = e.toString();
      onError(errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(String email) async {
    _isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    final url = Uri.parse('$_backendUrl/api/auth/email/otp');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email});
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.body.isEmpty) {
        errorMessage = 'Server mengembalikan respons kosong.';
        successMessage = null;
        return false;
      }

      final Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        errorMessage = 'Respons server tidak valid: ${e.toString()}';
        successMessage = null;
        return false;
      }

      if (response.statusCode == 201 && responseData['success'] == true) {
        successMessage =
            responseData['message'] ?? 'Kode OTP berhasil dikirim.';
        errorMessage = null;
        _currentEmail = email;
        return true;
      } else {
        errorMessage = responseData['message'] ?? 'Gagal meminta OTP.';
        successMessage = null;
        return false;
      }
    } catch (e) {
      errorMessage = 'Gagal mengirim permintaan: ${e.toString()}';
      successMessage = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCodeEmail(String email, String code) async {
    _isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    final url = Uri.parse('$_backendUrl/api/auth/email/verify');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'otp': code});
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.body.isEmpty) {
        errorMessage = 'Server mengembalikan respons kosong.';
        successMessage = null;
        return false;
      }

      final Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        errorMessage = 'Respons server tidak valid: ${e.toString()}';
        successMessage = null;
        return false;
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        if (data != null && data['token'] != null) {
          await _saveJwtToken(data['token']);
          successMessage = 'Verifikasi OTP berhasil.';
          errorMessage = null;
          return true;
        } else {
          errorMessage = 'Token tidak ditemukan dalam respons backend.';
          successMessage = null;
          return false;
        }
      } else {
        errorMessage = responseData['message'] ?? 'Gagal verifikasi OTP.';
        successMessage = null;
        return false;
      }
    } catch (e) {
      errorMessage = 'Error komunikasi backend: ${e.toString()}';
      successMessage = null;
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
      await _clearJwtToken();
      successMessage = null;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Gagal logout: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyPhoneNumberWithDialog(
    BuildContext context,
    String rawPhoneNumber,
    String routeName,
  ) async {
    if (!validatePhoneNumber(rawPhoneNumber)) {
      _showSnackBar(
        context,
        errorMessage ?? "Nomor telepon tidak valid",
        Colors.red,
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );

    await verifyPhoneNumberForOtp(
      rawPhoneNumber,
      (verificationId, formattedPhoneNumber) {
        if (context.mounted) {
          Navigator.pop(context);
          setupOtpSession(
            phoneNumber: formattedPhoneNumber,
            verificationId: verificationId,
            type: 'phone',
          );
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
  }

  Future<String?> _getFirebaseTokenSafely() async {
    final now = DateTime.now();
    final bool shouldThrottle =
        _lastTokenRequest != null &&
        now.difference(_lastTokenRequest!) < _tokenRequestCooldown;

    if (shouldThrottle) {
      errorMessage = "Terlalu banyak permintaan token. Tunggu 30 detik.";
      return null;
    }

    if (_firebaseUser == null) {
      errorMessage = "User tidak terautentikasi.";
      return null;
    }

    try {
      _lastTokenRequest = now;
      return await _firebaseUser!.getIdToken(false);
    } catch (e) {
      errorMessage = "Gagal mendapatkan token Firebase: ${e.toString()}";
      return null;
    }
  }
}