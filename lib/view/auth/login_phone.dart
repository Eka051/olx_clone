import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/widgets/app_filled_button.dart';

class LoginPhone extends StatelessWidget {
  const LoginPhone({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.of(context).colors.primary;
    return Scaffold(
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
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
                      children: [
                        Text(
                          'Masukkan nomor telepon Anda',
                          style: AppTheme.of(
                            context,
                          ).textStyle.heading2.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
                                keyboardType: TextInputType.phone,
                                maxLength: 12,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Nomor Telepon',
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth-option');
                  },
                  text: 'Lanjut',
                  color: AppTheme.of(context).colors.primary,
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
