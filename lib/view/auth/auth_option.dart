import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';

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
                          onTap: () {},
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
                    height: 300,
                    color: AppTheme.of(context).colors.primary,
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
