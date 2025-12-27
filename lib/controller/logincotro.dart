import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthapp/view/adminallscreen.dart';
import 'package:healthapp/view/hospitalallscreen.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // ==========================
  // Snackbar helper
  // ==========================
  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ==========================
  // LOGIN FUNCTION
  // ==========================
 Future<void> login({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  if (email.isEmpty || password.isEmpty) {
    _showMsg(context, "Email and password required");
    return;
  }

  try {
    isLoading = true;
    notifyListeners();

    // ==========================
    // ADMIN LOGIN FIRST
    // ==========================
    if (email == "admin@gmail.com" && password == "admin12345") {
      _showMsg(context, "Admin login successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Adminallscreen()),
      );
      return;
    }

    // ==========================
    // FIREBASE LOGIN
    // ==========================
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ==========================
    // HOSPITAL LOGIN
    // ==========================
    final hospitalSnap = await _firestore
        .collection("hospitals")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (hospitalSnap.docs.isNotEmpty) {
      final data = hospitalSnap.docs.first.data();

      if (data["isApproved"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Hospitalallscreen()),
        );
      } else {
        await _auth.signOut();
        _showMsg(context, "Hospital approval pending");
      }
      return;
    }

    // ==========================
    // DOCTOR LOGIN
    // ==========================
    final doctorSnap = await _firestore
        .collection("doctors")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (doctorSnap.docs.isNotEmpty) {
      final data = doctorSnap.docs.first.data();

      if (data["isApproved"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Hospitalallscreen()),
        );
      } else {
        await _auth.signOut();
        _showMsg(context, "Doctor approval pending");
      }
      return;
    }

    await _auth.signOut();
    _showMsg(context, "No account found");

  } on FirebaseAuthException catch (e) {
    _showMsg(context, e.message ?? "Login failed");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}