import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/firebase_options.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/view/auth/auth_option.dart';
import 'package:olx_clone/view/auth/input_otp.dart';
import 'package:olx_clone/view/auth/login.dart';
import 'package:olx_clone/view/auth/login_email.dart';
import 'package:olx_clone/view/auth/login_phone.dart';
import 'package:olx_clone/view/home/home_view.dart';
import 'package:olx_clone/view/splashscreen/splashscreen_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: const OlxClone(),
    ),
  );
}

class OlxClone extends StatelessWidget {
  const OlxClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: AppTheme.createTextTheme(ThemeData.light().textTheme),
      ),
      // home: const SplashscreenView(),
      debugShowCheckedModeBanner: false,
      routes: {
        AppRoutes.splash: (_) => const SplashscreenView(),
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.authOption: (_) => const AuthOption(),
        AppRoutes.loginPhone: (_) => const LoginPhone(),
        AppRoutes.loginEmail: (_) => const LoginEmail(),
        AppRoutes.home: (_) => const HomeView(),
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == AppRoutes.inputOtp) {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder:
                (context) => InputOtp(
                  phoneNumber: args?['phoneNumber'] ?? '',
                  verificationId: args?['verificationId'] ?? '',
                ),
          );
        }
      },
    );
  }
}
