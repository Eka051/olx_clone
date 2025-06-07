import 'package:firebase_app_check/firebase_app_check.dart';
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
import 'package:olx_clone/view/home/navbar.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.playIntegrity,
//     appleProvider: AppleProvider.apppAttest,
//     webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
//   );
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AuthProviderApp()),
//       ],
//       child: const OlxClone(),
//     ),
//   );
// }

// class OlxClone extends StatelessWidget {
//   const OlxClone({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         textTheme: AppTheme.createTextTheme(ThemeData.light().textTheme),
//       ),
//       debugShowCheckedModeBanner: false,
//       routes: {
//         AppRoutes.splash: (_) => const SplashscreenView(),
//         AppRoutes.login: (_) => const LoginView(),
//         AppRoutes.authOption: (_) => const AuthOption(),
//         AppRoutes.loginPhone: (_) => const LoginPhone(),
//         AppRoutes.loginEmail: (_) => const LoginEmail(),
//         AppRoutes.home: (_) => const HomeView(),
//       },
//       // Ganti route awal ke HomeView langsung tanpa login
//       initialRoute: AppRoutes.home,
//       onGenerateRoute: (settings) {
//         if (settings.name == '/input-otp') {
//           final args = settings.arguments as Map<String, dynamic>;

//           if (args['type'] == 'phone') {
//             return MaterialPageRoute(
//               builder: (context) => InputOtp(
//                 phoneNumber: args['phoneNumber'],
//                 verificationId: args['verificationId'],
//                 type: 'phone',
//               ),
//             );
//           } else if (args['type'] == 'email') {
//             return MaterialPageRoute(
//               builder: (context) => InputOtp(
//                 email: args['email'],
//                 verificationId: args['verificationId'],
//                 type: 'email',
//               ),
//             );
//           }
//         }
//         return null;
//       },
//     );
//   }
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OLX Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        primarySwatch: Colors.blue,
      ),
      home: const Navbar(),
    );
  }
}
