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
  MyApp({required this.isLoggedIn, required this.userType, super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mother\'s Tiffin',
      theme: LightThemes.theme1,
      darkTheme: DarkThemes.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/intro': (context) => AuthScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/pwreset': (context) => const ResetPasswordScreen(),
        '/details': (context) => MenuDetailsScreen(),
      },
      home: (FirebaseAuth.instance.currentUser != null)
          ? GetScreen(userType)
          : AuthScreen(),
    );
  }
}

Widget GetScreen(String userType) {
  switch (userType) {
    // case 'admin':
    //   return MainScreen();
    case 'admin':
      return AdminHomeScreen();
    default:
      return HomeScreen();
  }
}
