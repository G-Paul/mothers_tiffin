import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/admin/admin_home.dart';
import 'screens/auth/intro.dart';
import 'screens/auth/reset_password.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/login_email.dart';
import 'screens/home.dart';
import 'screens/shared/user_details.dart';
import 'screens/checkout.dart';
import 'screens/payment.dart';
import 'screens/feedback.dart';
import 'screens/admin/get_feedback.dart';
import 'screens/admin/order_history.dart';
import 'screens/utils/cart_provider.dart';

import 'firebase_options.dart';
import 'app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userType = prefs.getString('userType') ?? '';
  runApp(MyApp(isLoggedIn: isLoggedIn, userType: userType));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userType;
  const MyApp({
    required this.isLoggedIn,
    required this.userType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Mother\'s Tiffin',
        theme: LightThemes.theme1,
        darkTheme: DarkThemes.theme1,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => const HomeScreen(),
          '/admin_home': (context) => const AdminHomeScreen(),
          '/intro': (context) => const AuthScreen(),
          '/signin': (context) => const SignInScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/pwreset': (context) => const ResetPasswordScreen(),
          '/details': (context) => const MenuDetailsScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/feedback': (context) => const FeedBackScreen(),
          '/feedback_admin': (context) => const AdminFeedbackScreen(),
          '/order_history': (context) => const OrderHistoryScreen(),
        },
        home: MyAppWrapper(userType: userType),
      ),
    );
  }
}

class MyAppWrapper extends StatelessWidget {
  final String userType;
  const MyAppWrapper({
    required this.userType,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (FirebaseAuth.instance.currentUser != null)
        ? getScreen(userType)
        : const AuthScreen();
  }
}

Widget getScreen(String userType) {
  switch (userType) {
    case 'admin':
      return const AdminHomeScreen();
    default:
      return const HomeScreen();
  }
}
