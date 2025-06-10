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
import 'package:olx_clone/view/home/navbar.dart';
import 'package:olx_clone/view/sell/upload_product_screen.dart';
import 'package:olx_clone/view/profile/my_ads_screen.dart';
import 'package:olx_clone/view/package/package_cart_screen.dart';
import 'package:olx_clone/view/package/purchase_history_screen.dart'; // ✅ Tambahan
import 'package:olx_clone/view/profile/profile_page.dart';
import 'package:olx_clone/view/notification/notification_page.dart';
import 'package:provider/provider.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.playIntegrity,
//     appleProvider: AppleProvider.appAttest,
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
//
// class OlxClone extends StatelessWidget {
//   const OlxClone({super.key});
//
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
//
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProviderApp()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OLX Clone',
      theme: ThemeData(
        textTheme: AppTheme.createTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const Navbar(),
        '/upload': (_) => const UploadProductScreen(),
        '/my-ads': (_) => const MyAdsScreen(),
        '/profile': (_) => const ProfilePage(),
        '/home': (_) => const HomeView(),
        '/notification': (_) => const NotificationPage(),
        '/package': (_) => const PackageCartScreen(),
        '/purchase-history': (_) => const PurchaseHistoryScreen(), // ✅ Tambahan
      },
    );
  }
}
