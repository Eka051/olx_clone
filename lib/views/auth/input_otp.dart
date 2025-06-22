import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:provider/provider.dart';

class InputOtp extends StatefulWidget {
  final String type;

  const InputOtp({super.key, required this.type});

  @override
  State<InputOtp> createState() => _InputOtpState();
}

class _InputOtpState extends State<InputOtp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderApp>(
      builder: (context, authProvider, child) {
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
            body: SafeArea(
              bottom: false,
              child: Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang kembali',
                                style: AppTheme.of(
                                  context,
                                ).textStyle.heading2.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.of(context).colors.primary,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Kami mengirim kode 6 digit ke ',
                                        style: AppTheme.of(
                                          context,
                                        ).textStyle.bodyLarge.copyWith(
                                          fontSize: 12,
                                          color:
                                              AppTheme.of(
                                                context,
                                              ).colors.primary,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                authProvider
                                                    .getOtpDisplayTarget(),
                                            style: AppTheme.of(
                                              context,
                                            ).textStyle.bodyLarge.copyWith(
                                              fontSize: 12,
                                              color:
                                                  AppTheme.of(
                                                    context,
                                                  ).colors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child: TextField(
                                        controller:
                                            authProvider.otpControllers[index],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        enabled: !authProvider.isVerifying,
                                        style: AppTheme.of(context)
                                            .textStyle
                                            .heading2
                                            .copyWith(fontSize: 20),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                          hintText: '-',
                                          hintStyle: AppTheme.of(
                                            context,
                                          ).textStyle.bodyLarge.copyWith(
                                            fontSize: 20,
                                            color: AppTheme.of(
                                              context,
                                            ).colors.primary.withAlpha(120),
                                          ),
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  AppTheme.of(
                                                    context,
                                                  ).colors.primary,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  AppTheme.of(
                                                    context,
                                                  ).colors.primary,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  AppTheme.of(
                                                    context,
                                                  ).colors.secondary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty && index < 5) {
                                            FocusScope.of(context).nextFocus();
                                          } else if (value.isEmpty &&
                                              index > 0) {
                                            FocusScope.of(
                                              context,
                                            ).previousFocus();
                                          }

                                          authProvider.handleOtpInputChange(
                                            context,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),

                              TextButton(
                                onPressed:
                                    authProvider.isVerifying
                                        ? null
                                        : () => authProvider.handleResendOtp(
                                          context,
                                        ),
                                child: Text(
                                  authProvider.getResendButtonText(),
                                  style: AppTheme.of(
                                    context,
                                  ).textStyle.titleMedium.copyWith(
                                    color: AppTheme.of(context).colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              if (authProvider.isVerifying)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
