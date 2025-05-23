import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pin-code_page.dart'; // Import the PinCodePage
import 'colors.dart'; // Import the colors file
import 'AuthService.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _auth = AuthService();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bank Logo
                Image.asset(
                  'assets/PesoWiseLogo.png',
                  height: 50, // Adjust the height
                ),

                const SizedBox(height: 30),

                // Name Input
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm Password Input
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign-Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      String name = _nameController.text;
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      String confirmPassword = _confirmPasswordController.text;

                      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
                        if (password == confirmPassword) {
                          await _signupfunc_(); // Make sure this completes before moving on
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PinCodePage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match!")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill in all fields!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 16),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigate back to Login Page
                      },
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _signupfunc_() async {
    final user = await _auth.createUserWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null) {
      log("User Created Successfully");
      await _savedUserData(user.uid); // Await this to avoid async race
      // DO NOT navigate here anymore
    }
  }

  _savedUserData(String userid) async {
    final users = FirebaseFirestore.instance;
    final bankAccounts = FirebaseFirestore.instance;

    final existingUser = await users
        .collection('users-data')
        .where('email', isEqualTo: _emailController.text)
        .limit(1)
        .get();

    if (existingUser.docs.isEmpty) {
      // 🔢 Generate unique account number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueNumber = timestamp.toString().substring(timestamp.toString().length - 6);
      final accountNumber = "5-$uniqueNumber";

      await users.collection('user-data').doc(userid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'pass': _passwordController.text,
      });

      await bankAccounts.collection('bank-account').doc(userid).set({
        'account-number': accountNumber,
        'balance': 0,
      });

      print('User added.');
    } else {
      print('User with this email already exists.');
    }
  }
}