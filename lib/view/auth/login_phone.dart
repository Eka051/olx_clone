import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/widgets/app_filled_button.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/auth_provider.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx_clone/utils/const.dart';

class LoginPhone extends StatefulWidget {
  const LoginPhone({super.key});

  @override
  State<LoginPhone> createState() => _LoginPhoneState();
}

class _LoginPhoneState extends State<LoginPhone> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app.AuthProvider>(context);
    final primaryColor = AppTheme.of(context).colors.primary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: primaryColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: primaryColor),
                onPressed:
                    () =>
                        Navigator.pushReplacementNamed(context, '/auth-option'),
              ),
              title: Text(
                'Login',
                style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                  color: primaryColor,
                  fontSize: 20,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: Colors.grey.shade300, height: 1.0),
              ),
            ),
          ),
        ),
        backgroundColor: primaryColor,
        body: Container(
          color: AppTheme.of(context).colors.surface,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/avatar.png',
                    ),
                    radius: 40,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Masukkan nomor telepon Anda',
                          style: AppTheme.of(
                            context,
                          ).textStyle.heading2.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.of(context).colors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            'Kami akan mengirimkan kode verifikasi ke nomor telepon Anda',
                            style: AppTheme.of(
                              context,
                            ).textStyle.bodyLarge.copyWith(
                              fontSize: 12,
                              color: AppTheme.of(context).colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: TextEditingController(text: '+62'),
                                enabled: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Negara',
                                  labelStyle: AppTheme.of(
                                    context,
                                  ).textStyle.bodyLarge.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.of(context).colors.primary,
                                  ),
                                  hintStyle: AppTheme.of(
                                    context,
                                  ).textStyle.bodyLarge.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.of(context).colors.primary,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          AppTheme.of(context).colors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: authProvider.phoneNumberController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 12,
                                decoration: InputDecoration(
                                  labelText: 'Nomor Telepon',
                                  errorText: authProvider.errorMessage,
                                  errorStyle: AppTheme.of(
                                    context,
                                  ).textStyle.bodyLarge.copyWith(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                  counterText: '',
                                  labelStyle: AppTheme.of(
                                    context,
                                  ).textStyle.bodyLarge.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.of(context).colors.primary,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          AppTheme.of(context).colors.primary,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          AppTheme.of(context).colors.secondary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  authProvider.validatePhoneNumber(value);
                                },
                                onSubmitted: (value) {
                                  authProvider.validatePhoneNumber(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                AppFilledButton(
                  onPressed:
                      authProvider.isPhoneValid
                          ? () async {
                            final phoneNumber =
                                '+62${authProvider.phoneNumberController.text}';

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            await authProvider.verifyPhoneNumber(
                              phoneNumber,
                              (PhoneAuthCredential credential) async {
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                                final success = await authProvider
                                    .signInWithCredential(credential);
                                if (success && mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                }
                              },
                              (FirebaseAuthException e) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Verifikasi gagal: ${e.message}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }, // codeSent
                              (String verificationId, int? resendToken) {
                                if (mounted) {
                                  Navigator.pop(context); // Dismiss loading
                                  // Navigate using named route with arguments
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.inputOtp,
                                    arguments: {
                                      'phoneNumber': phoneNumber,
                                      'verificationId': verificationId,
                                    },
                                  );
                                }
                              },
                              // codeAutoRetrievalTimeout
                              (String verificationId) {
                                // Handle timeout if needed
                              },
                            );
                          }
                          : null,
                  text: 'Lanjut',
                  color:
                      authProvider.isPhoneValid
                          ? AppTheme.of(context).colors.primary
                          : Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16,
                  widthButton: double.infinity,
                  isTextCentered: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
