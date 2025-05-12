import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:provider/provider.dart';

class InputOtp extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const InputOtp({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<InputOtp> createState() => _InputOtpState();
}

class _InputOtpState extends State<InputOtp> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void verifyOtp(String otp) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.verifyOTP(widget.verificationId, smsCode: otp).then((success) {
      if (success) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
  }

  Future<void> resendOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendOTP('+62${widget.phoneNumber}');

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP telah dikirim ulang'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Gagal mengirim ulang OTP',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.of(context).colors.primary;
    final formattedPhoneNumber = widget.phoneNumber;
    final authProvider = Provider.of<AuthProvider>(context);

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          AppTheme.of(context).colors.primary,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            formattedPhoneNumber,
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
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login-phone');
                                },
                                icon: Icon(
                                  CupertinoIcons.square_pencil,
                                  size: 28,
                                  color: AppTheme.of(context).colors.primary,
                                ),
                                padding: const EdgeInsets.only(left: 8.0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: TextField(
                                controller: _otpControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: AppTheme.of(
                                  context,
                                ).textStyle.heading2.copyWith(fontSize: 20),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10), // Adjusted padding
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
                                      AppTheme.of(context).colors.primary,
                                  ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                      AppTheme.of(context).colors.primary,
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
                                  if (value.isNotEmpty) {
                                  if (index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                  final otp =
                                    _otpControllers
                                      .map(
                                        (controller) => controller.text,
                                      )
                                      .join();

                                  if (otp.length == 6) {
                                    authProvider.handleOTPVerification(
                                    widget.verificationId,
                                    otp,
                                    context,
                                    );
                                  }
                                  } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                  }
                                },
                                ),
                              ),
                              );
                            }),
                            ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              resendOTP();
                            },
                            child: Text(
                              'Kirim ulang kode melalui SMS',
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
  }
}
