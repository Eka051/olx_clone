import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/theme.dart';

class SplashscreenView extends StatefulWidget {
  const SplashscreenView({super.key});

  @override
  State<SplashscreenView> createState() => _SplashscreenViewState();
}

class _SplashscreenViewState extends State<SplashscreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Center(
          child: Container(
            width: double.infinity,
            color: AppTheme.of(context).colors.splash,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/LOGO-MEMBER-ASTRA.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 10),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Text(
                    '#PusatnyaNgeDeal',
                    style: AppTheme.of(context).textStyle.bodyLarge.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
