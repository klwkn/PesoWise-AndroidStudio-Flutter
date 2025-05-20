import 'package:flutter/material.dart';
import 'welcome_page.dart'; // Import your login page
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
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()), // Navigate to Welcome Page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray // Splash screen background color
      ,body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace Icon with your custom image
            Image.asset(
              'assets/PesoWiseLogo.png',
              height: 50,          // Adjust the height
            ),
            const SizedBox(height: 20),
            const Text(
              "We Found Ways",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}