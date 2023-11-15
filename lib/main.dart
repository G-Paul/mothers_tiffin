import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mothers_tiffin/screens/admin/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mothers_tiffin/screens/auth/intro.dart';
import 'package:mothers_tiffin/screens/auth/reset_password.dart';
import 'package:mothers_tiffin/screens/auth/signup.dart';
import 'package:mothers_tiffin/screens/home.dart';
import 'package:mothers_tiffin/screens/user_details.dart';
import 'package:mothers_tiffin/screens/checkout.dart';
import 'firebase_options.dart';

import 'app_themes.dart';

//screens
import 'package:mothers_tiffin/screens/auth/login_email.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //only portrait mode
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
  const MyApp({required this.isLoggedIn, required this.userType, super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
      home: (FirebaseAuth.instance.currentUser != null)
          ? getScreen(userType)
          : const AuthScreen(),
    );
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
