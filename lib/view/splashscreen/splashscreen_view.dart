import 'package:flutter/material.dart';
import 'package:olx_clone/utils/theme.dart';

class SplashscreenView extends StatelessWidget {
  const SplashscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          color: AppTheme.of(context).colors.splash,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/LOGO-MEMBER-ASTRA.png',
                width: 150,
                height: 150,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Text(
                  '#PusatnyaNgeDeal',
                  style: AppTheme.of(context).textStyle.bodyLarge.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
