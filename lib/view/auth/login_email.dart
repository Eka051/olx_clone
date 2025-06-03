import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/widgets/app_filled_button.dart';
import 'package:provider/provider.dart';
import 'package:olx_clone/providers/auth_provider.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({super.key});

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderApp>(context);
    final primaryColor = AppTheme.of(context).colors.primary;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.png'),
                radius: 40,
              ),
              const SizedBox(height: 20),
              Text(
                'Masukkan Email Anda',
                style: AppTheme.of(context).textStyle.heading2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Email',
                style: AppTheme.of(context).textStyle.titleSmall.copyWith(
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: authProvider.emailController,
                style: AppTheme.of(context).textStyle.bodyMedium.copyWith(
                  fontSize: 16,
                  color: primaryColor,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  fillColor: AppTheme.of(context).colors.primary.withAlpha(30),
                  filled: true,
                  errorText: authProvider.errorMessage,
                  errorStyle: AppTheme.of(context).textStyle.bodyLarge.copyWith(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                  hintText: 'Email',
                  labelStyle: AppTheme.of(context).textStyle.bodyLarge.copyWith(
                    fontSize: 14,
                    color: primaryColor,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.of(context).colors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: authProvider.validateEmail,
                onSubmitted: authProvider.validateEmail,
              ),
              const Spacer(),
              AppFilledButton(
                onPressed:
                    authProvider.isEmailValid
                        ? () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          final success = await authProvider.signUpWithEmail(
                            authProvider.emailController.text,
                          );

                          if (success && mounted) {
                            Navigator.pop(context);
                          }
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'OTP telah dikirim ke email Anda',
                                  style: AppTheme.of(context)
                                      .textStyle
                                      .bodyMedium
                                      .copyWith(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushNamed(
                              context,
                              '/input-otp',
                              arguments: {
                                'email': authProvider.emailController.text,
                                'type': 'email',
                              },
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  authProvider.errorMessage ??
                                      'Gagal mengirim OTP',
                                  style: AppTheme.of(context)
                                      .textStyle
                                      .bodyMedium
                                      .copyWith(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                        : null,
                text: 'Lanjut',
                color: authProvider.isEmailValid ? primaryColor : Colors.grey,
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
    );
  }
}
