import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_donations_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Community Pantry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // 2. This sets Poppins as the default font for the whole app
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => MainLayout(),
        '/my_donations': (context) => MyDonationsScreen(),
        '/messages': (context) => MessagesScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}