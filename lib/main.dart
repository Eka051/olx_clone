import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/firebase_options.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/category_provider.dart';
import 'package:olx_clone/providers/chat_filter_provider.dart';
import 'package:olx_clone/providers/chat_list_provider.dart';
import 'package:olx_clone/providers/chat_room_provider.dart';
import 'package:olx_clone/providers/create_product_provider.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/views/auth/auth_option.dart';
import 'package:olx_clone/views/auth/input_otp.dart';
import 'package:olx_clone/views/auth/login.dart';
import 'package:olx_clone/views/auth/login_email.dart';
import 'package:olx_clone/views/auth/login_phone.dart';
import 'package:olx_clone/views/category/category_view.dart';
import 'package:olx_clone/views/main_screen.dart';
import 'package:olx_clone/views/splashscreen/splashscreen_view.dart';
import 'package:olx_clone/views/product/select_category_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProviderApp()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => ChatFilterProvider()),
        ChangeNotifierProxyProvider<AuthProviderApp, ChatListProvider>(
          create:
              (context) => ChatListProvider(
                Provider.of<AuthProviderApp>(context, listen: false),
              ),
          update:
              (context, auth, previous) => previous ?? ChatListProvider(auth),
        ),
        ChangeNotifierProvider(create: (context) => ChatRoomProvider()),
        ChangeNotifierProvider(create: (context) => CreateProductProvider()),
      ],
      child: const OlxClone(),
    ),
  );
}

class OlxClone extends StatelessWidget {
  const OlxClone({super.key});

  @override
  Widget build(BuildContext context) {
    SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: AppTheme.of(context).colors.primary,
    );
    return MaterialApp(
      theme: ThemeData(
        textTheme: AppTheme.createTextTheme(ThemeData.light().textTheme),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        AppRoutes.splash: (_) => const SplashscreenView(),
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.authOption: (_) => const AuthOption(),
        AppRoutes.loginPhone: (_) => const LoginPhone(),
        AppRoutes.loginEmail: (_) => const LoginEmail(),
        AppRoutes.home: (_) => const MainScreen(),
        AppRoutes.category: (_) => const CategoryView(),
        '/select-category': (_) => const SelectCategoryView(),
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        if (settings.name == '/input-otp') {
          final args = settings.arguments as Map<String, dynamic>;

          if (args['type'] == 'phone') {
            return MaterialPageRoute(
              builder:
                  (context) => InputOtp(
                    phoneNumber: args['phoneNumber'],
                    verificationId: args['verificationId'],
                    type: 'phone',
                  ),
            );
          } else if (args['type'] == 'email') {
            return MaterialPageRoute(
              builder:
                  (context) => InputOtp(
                    email: args['email'],
                    verificationId: args['verificationId'],
                    type: 'email',
                  ),
            );
          }
        }
        return null;
      },
    );
  }
}
