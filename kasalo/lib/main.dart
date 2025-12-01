import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import this
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_donations_screen.dart'; // Add this line
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Community Pantry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set the initial route to the Welcome Screen as per source [18]
      initialRoute: '/', 
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => MainLayout(),
        '/my_donations': (context) => MyDonationsScreen(), // Add this line!
        '/messages': (context) => MessagesScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}