import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Signup error: $e");
      return null;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Login error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      log("Sign out error: $e");
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      log("Google sign-in error: $e");
      return null;
    }
  }

  Future<void> createTransaction(String userId, String type, double amount) async {
    final userDoc = FirebaseFirestore.instance.collection('bank-account').doc(userId);
    final historyRef = FirebaseFirestore.instance
        .collection('transaction-history')
        .doc(userId)
        .collection('history');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      final data = snapshot.data() as Map<String, dynamic>?;
      double currentBalance = (data?['balance'] ?? 0).toDouble();

      if (type == 'Transfer' && currentBalance < amount) {
        throw Exception("Insufficient balance.");
      }

      double newBalance = type == 'Deposit'
          ? currentBalance + amount
          : currentBalance - amount;

      transaction.update(userDoc, {'balance': newBalance});

      transaction.set(historyRef.doc(), {
        'type': type,
        'amount': amount,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }
}
