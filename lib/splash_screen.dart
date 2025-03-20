import 'package:flutter/material.dart';
import 'login_page.dart'; // Import Login Page
import 'colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance, size: 100, color: AppColors.primary), // Logo
            const SizedBox(height: 20),
            const Text(
              "PesoWise Banks",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
          ],
        ),
      ),
    );
  }
}