import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import Splash Screen
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  runApp(const BankApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class BankApp extends StatelessWidget {
  const BankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bank App",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(), // Start with Splash Screen
    );
  }
}
