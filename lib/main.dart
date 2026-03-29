import 'package:eccomerce_app/controllers/auth_service.dart';

import 'package:eccomerce_app/providers/admin_provider.dart';
import 'package:eccomerce_app/providers/order_provider.dart';
import 'package:eccomerce_app/screens/coupon.dart';
import 'package:eccomerce_app/screens/home.dart';
import 'package:eccomerce_app/screens/modify_product.dart';
import 'package:eccomerce_app/screens/modify_promo.dart';
import 'package:eccomerce_app/screens/onboarding.dart';
import 'package:eccomerce_app/screens/order_sucess.dart';
import 'package:eccomerce_app/screens/promo_banner.dart';
import 'package:eccomerce_app/screens/view_products.dart';
import 'package:firebase_core/firebase_core.dart';
// Import other screens as needed
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/categories_page.dart';
import 'screens/login_page.dart';
import 'screens/products_page.dart';
import 'screens/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(
    onboardingCompleted: onboardingCompleted,
  ));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  bool? onboardingCompleted;

  MyApp({super.key, this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProvider(
            create: (_) => OrderProvider()..initialize(),
          ),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
        ],
        child: MaterialApp(
          title: 'Ecommerce App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // Set initial route based on onboarding status
          initialRoute: onboardingCompleted! ? '/check' : '/onboarding',

          // Define all your routes
          routes: {
            '/onboarding': (context) => const Onboarding(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignUpPage(),
            '/home': (context) => const Home(),
            '/check': (context) => const CheckUser(),
            '/category': (context) => CategoriesPage(),
            '/products': (context) => ProductsPage(),
            '/add_product': (context) => ModifyProduct(),
            '/view_product': (context) => ViewProducts(),
            '/promos': (context) => PromoBanner(),
            '/modify_promos': (context) => ModifyPromo(),
            '/coupon': (context) => Coupon(),
            '/orders': (context) => OrdersPage(),

            // Add more routes as needed
            // '/profile': (context) => const ProfilePage(),
            // '/cart': (context) => const CartPage(),
            // '/product-detail': (context) => const ProductDetailPage(),
          },

          // Handle unknown routes
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const LoginPage(),
            );
          },
        ));
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLoggedIn().then(
      (value) {
        if (value == true) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
