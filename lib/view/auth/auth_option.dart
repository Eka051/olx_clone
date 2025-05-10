import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/view/auth/login_phone.dart';
import 'package:olx_clone/view/splashscreen/splashscreen_view.dart';
import 'package:olx_clone/widgets/app_filled_button.dart';

class AuthOption extends StatelessWidget {
  const AuthOption({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
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
                              MaterialPageRoute(builder: (context) => const SplashscreenView()),
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
                                MaterialPageRoute(builder: (context) => const LoginPhone()),
                              );
                            },
                            text: 'Login/Daftar dengan Telepon',
                            icon: Icons.phone_android_rounded,
                            widthButton: 350,
                          ),
                          AppFilledButton(
                            onPressed: () {},
                            text: 'Login/Daftar dengan Google',
                            icon: FontAwesomeIcons.google,
                            widthButton: 350,
                          ),
                          AppFilledButton(
                            onPressed: () {},
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
    );
  }
}
