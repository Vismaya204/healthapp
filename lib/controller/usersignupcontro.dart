import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/model/model.dart';

class SignupController extends ChangeNotifier {
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================
  // ✅ USER SIGNUP (MODEL BASED)
  // ==========================
 Future<void> signupUser({
  required AppUserModel user,
  required String password,
  required BuildContext context,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    // 🔐 1️⃣ Firebase Authentication
    final cred = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );

    // 🔁 2️⃣ ATTACH UID + CREATED TIME  ✅ ADD HERE
    final model = user.copyWith(
      uid: cred.user!.uid,
      createdAt: DateTime.now(),
    );

    // 🔥 3️⃣ SAVE TO FIRESTORE
    await _firestore
        .collection("users")
        .doc(model.uid)
        .set(model.toMap());

    _showMessage(context, "Signup successful");
  } catch (e) {
    _showMessage(context, e.toString());
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  // ==========================
  // 🔔 SNACKBAR
  // ==========================
  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
