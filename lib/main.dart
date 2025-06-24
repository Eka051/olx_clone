import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:olx_clone/firebase_options.dart';
import 'package:olx_clone/providers/notification_provider.dart';
import 'package:olx_clone/utils/firebase_config.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/providers/category_provider.dart';
import 'package:olx_clone/providers/chat_filter_provider.dart';
import 'package:olx_clone/providers/chat_list_provider.dart';
import 'package:olx_clone/providers/chat_room_provider.dart';
import 'package:olx_clone/providers/home_provider.dart';
import 'package:olx_clone/providers/ad_provider.dart';
import 'package:olx_clone/providers/premium_package_provider.dart';
import 'package:olx_clone/providers/product_provider.dart';
import 'package:olx_clone/providers/profile_provider.dart';
import 'package:olx_clone/utils/const.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/views/auth/auth_option.dart';
import 'package:olx_clone/views/auth/input_otp.dart';
import 'package:olx_clone/views/auth/login_email.dart';
import 'package:olx_clone/views/auth/login_phone.dart';
import 'package:olx_clone/views/category/category_view.dart';
import 'package:olx_clone/views/category/category_products_view.dart';
import 'package:olx_clone/views/main_screen.dart';
import 'package:olx_clone/views/adPackage/ad_package_view.dart';
import 'package:olx_clone/views/adPackage/cart_view.dart';
import 'package:olx_clone/views/adPackage/payment_view.dart';
import 'package:olx_clone/views/notification/notification_view.dart';
import 'package:olx_clone/views/premium%20package/premium_package_view.dart';
import 'package:olx_clone/views/profile/edit_profile_view.dart';
import 'package:olx_clone/views/product/product_detail_view.dart';
import 'package:olx_clone/views/product/create_product_view.dart';
import 'package:olx_clone/views/splashscreen/splashscreen_view.dart';
import 'package:olx_clone/views/product/select_category_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseConfig.configureFirebase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProviderApp()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => ChatFilterProvider()),
        ChangeNotifierProxyProvider<AuthProviderApp, NotificationProvider>(
          create: (context) => NotificationProvider(),
          update: (context, auth, previous) {
            previous ??= NotificationProvider();
            previous.updateAuth(auth);
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<AuthProviderApp, ProfileProvider>(
          create: (context) => ProfileProvider(context.read<AuthProviderApp>()),
          update: (context, auth, previous) {
            if (previous != null && !previous.disposed) {
              return previous;
            }
            return ProfileProvider(auth);
          },
        ),
        ChangeNotifierProxyProvider2<
          AuthProviderApp,
          ProfileProvider,
          ChatListProvider
        >(
          create:
              (context) => ChatListProvider(
                context.read<AuthProviderApp>(),
                context.read<ProfileProvider>(),
              ),
          update:
              (context, auth, profile, previous) =>
                  previous ?? ChatListProvider(auth, profile),
        ),
        ChangeNotifierProxyProvider<AuthProviderApp, ChatRoomProvider>(
          create:
              (context) => ChatRoomProvider(context.read<AuthProviderApp>()),
          update: (context, auth, previous) => ChatRoomProvider(auth),
        ),
        ChangeNotifierProxyProvider2<
          AuthProviderApp,
          ProfileProvider,
          ProductProvider
        >(
          create:
              (context) => ProductProvider(
                context.read<AuthProviderApp>(),
                context.read<ProfileProvider>(),
              ),
          update:
              (context, auth, profile, previous) =>
                  ProductProvider(auth, profile),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => HomeProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProviderApp, PremiumPackageProvider>(
          create:
              (context) =>
                  PremiumPackageProvider(context.read<AuthProviderApp>()),
          update: (context, auth, previous) => PremiumPackageProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProviderApp, AdProvider>(
          create: (context) => AdProvider(),
          update: (context, auth, previous) {
            previous ??= AdProvider();
            previous.updateAuth(auth);
            return previous;
          },
        ),
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
        AppRoutes.authOption: (_) => const AuthOption(),
        AppRoutes.loginPhone: (_) => const LoginPhone(),
        AppRoutes.loginEmail: (_) => const LoginEmail(),
        AppRoutes.home: (_) => const MainScreen(),
        AppRoutes.category: (_) => const CategoryView(),
        AppRoutes.selectCategory: (_) => const SelectCategoryView(),
        AppRoutes.productDetails: (_) => const ProductDetailView(),
        AppRoutes.premiumPackages: (_) => const PremiumPackageView(),
        AppRoutes.adPackages: (_) => const AdPackageView(),
        AppRoutes.cart: (_) => const CartView(),
        AppRoutes.editProfile: (_) => const EditProfileView(),
        AppRoutes.notification: (_) => const NotificationView(),
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        if (settings.name == '/input-otp') {
          return MaterialPageRoute(
            builder: (context) => const InputOtp(type: 'phone'),
          );
        }

        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MainScreen(initialTab: args?['initialTab']),
          );
        }

        if (settings.name == '/payment') {
          final invoiceNumber = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => PaymentView(invoiceNumber: invoiceNumber),
          );
        }

        if (settings.name == AppRoutes.createProduct) {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder:
                (context) => CreateProductView(
                  isEdit: args?['isEdit'] ?? false,
                  product: args?['product'],
                  selectedCategory: args?['selectedCategory'],
                ),
          );
        }

        if (settings.name == '/category-products') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) => CategoryProductsView(
                  categoryId: args['categoryId'],
                  categoryName: args['categoryName'],
                ),
          );
        }

        return null;
      },
    );
  }
}
