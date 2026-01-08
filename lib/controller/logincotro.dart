import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/adminallscreen.dart';
import 'package:healthapp/view/hospitalallscreen.dart';
import 'package:healthapp/view/userallscreen.dart'; // Create this screen

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // ==========================
  // ADMIN CREDENTIALS (HARD-CODED)
  // ==========================
  static const String adminEmail = "admin@healthapp.com";
  static const String adminPassword = "admin123";

  // ==========================
  // LOGIN
  // ==========================
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // ==========================
      // 1️⃣ ADMIN LOGIN CHECK
      // ==========================
      if (email == adminEmail && password == adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Adminallscreen()),
        );
        return;
      }

      // ==========================
      // 2️⃣ SIGN IN WITH FIREBASE AUTH
      // ==========================
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // ==========================
      // 3️⃣ CHECK HOSPITAL
      // ==========================
      final hospitalDoc =
          await _firestore.collection("hospitals").doc(uid).get();

      if (hospitalDoc.exists) {
        if (hospitalDoc["isApproved"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Hospitalallscreen()),
          );
        } else {
          _showMsg(context, "Hospital not approved yet");
          await _auth.signOut();
        }
        return;
      }

      // ==========================
      // 4️⃣ CHECK DOCTOR
      // ==========================
      final doctorDoc =
          await _firestore.collection("doctors").doc(uid).get();

      if (doctorDoc.exists) {
        if (doctorDoc["isApproved"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Hospitalallscreen()),
          );
        } else {
          _showMsg(context, "Doctor not approved yet");
          await _auth.signOut();
        }
        return;
      }

      // ==========================
      // 5️⃣ CHECK USER
      // ==========================
      final userDoc =
          await _firestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Userallscreen()),
        );
        return;
      }

      // ==========================
      // 6️⃣ NO ACCOUNT FOUND
      // ==========================
      _showMsg(context, "No account found");
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      String msg = "";
      if (e.code == 'user-not-found') msg = "No user found for this email";
      else if (e.code == 'wrong-password') msg = "Incorrect password";
      else msg = e.message ?? "Login failed";
      _showMsg(context, msg);
    } catch (e) {
      _showMsg(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

   Future<void> forgotpassword({
    required String email,
    required BuildContext context,
  }) async {
    if (email.isEmpty) {
      _showMsg(context, "Please enter your email");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _showMsg(context, "Password reset link sent to your email");

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email";
          break;
        case 'invalid-email':
          message = "Invalid email address";
          break;
        case 'too-many-requests':
          message = "Too many requests. Try again later";
          break;
        default:
          message = e.message ?? "Password reset failed";
      }

      _showMsg(context, message);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // SNACKBAR
  // ==========================
  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}