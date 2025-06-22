import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/views/auth/login_phone.dart';
import 'package:olx_clone/views/splashscreen/splashscreen_view.dart';
import 'package:olx_clone/widgets/app_filled_button.dart';
import 'package:provider/provider.dart';

class AuthOption extends StatefulWidget {
  const AuthOption({super.key});

  @override
  State<AuthOption> createState() => _AuthOptionState();
}

class _AuthOptionState extends State<AuthOption> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: AppTheme.of(context).colors.primary,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: Container(
                color: AppTheme.of(context).colors.surface,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppTheme.of(context).colors.primary,
                              size: 34,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const SplashscreenView(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.of(context).colors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Bantuan',
                                  style: AppTheme.of(
                                    context,
                                  ).textStyle.titleMedium.copyWith(
                                    color: AppTheme.of(context).colors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Image.asset(AppAssets.darkLogo, width: 250, height: 250),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      height: 280,
                      color: AppTheme.of(context).colors.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          spacing: 10,
                          children: [
                            AppFilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPhone(),
                                  ),
                                );
                              },
                              text: 'Login/Daftar dengan Telepon',
                              icon: Icons.phone_android_rounded,
                              widthButton: 350,
                            ),
                            Consumer<AuthProviderApp>(
                              builder: (context, authProvider, child) {
                                return AppFilledButton(
                                  onPressed:
                                      authProvider.isLoading
                                          ? null
                                          : () async {
                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);
                                            final navigator = Navigator.of(
                                              context,
                                            );

                                            bool isSuccess =
                                                await authProvider
                                                    .signInWithGoogle();

                                            if (mounted) {
                                              if (isSuccess) {
                                                navigator.pushReplacementNamed(
                                                  '/home',
                                                );
                                              } else {
                                                // Show error message if login failed
                                                final errorMsg =
                                                    authProvider.errorMessage ??
                                                    'Login gagal. Coba lagi.';
                                                scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(errorMsg),
                                                    backgroundColor: Colors.red,
                                                    duration: const Duration(
                                                      seconds: 4,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                  text:
                                      authProvider.isLoading
                                          ? 'Memproses...'
                                          : 'Login/Daftar dengan Google',
                                  icon:
                                      authProvider.isLoading
                                          ? null
                                          : FontAwesomeIcons.google,
                                  widthButton: 350,
                                );
                              },
                            ),
                            AppFilledButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login-email');
                              },
                              text: 'Login/Daftar dengan Email',
                              icon: Icons.email_outlined,
                              widthButton: 350,
                            ),
                            Text(
                              'Jika Anda login, Anda menerima \nSyarat dan Ketentuan serta Kebijakan Privasi OLX',
                              textAlign: TextAlign.center,
                              style: AppTheme.of(
                                context,
                              ).textStyle.bodyMedium.copyWith(
                                color: AppTheme.of(context).colors.surface,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
