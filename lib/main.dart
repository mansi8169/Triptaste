import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(TripTasteApp());
}

class TripTasteApp extends StatelessWidget {
  const TripTasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripTaste',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF0B1C2D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1C2D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),

      home: FirebaseAuth.instance.currentUser == null
          ? WelcomeScreen()
          : HomeScreen(),
    );
  }
}
