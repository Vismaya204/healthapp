import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signupUser({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phoneNumber.isEmpty ||
          location.isEmpty) {
        throw "Please fill all fields";
      }

      UserCredential userCred =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "uid": userCred.user!.uid,
        "username": username,
        "email": email,
        "phone": phoneNumber,
        "location": location,
        "createdAt": Timestamp.now(),
      });

      _showMessage(context, "Signup successful");
    } catch (e) {
      _showMessage(context, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ FIX: Add this method
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
