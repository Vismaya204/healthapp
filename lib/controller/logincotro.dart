import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:healthapp/view/adminallscreen.dart';
import 'package:healthapp/view/hospitalallscreen.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===============================
  // SHOW MESSAGE
  // ===============================
  void showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===============================
  // LOGIN
  // ===============================
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // -------------------------------
      // ADMIN LOGIN
      // -------------------------------
      if (email == "admin@gmail.com" && password == "admin1234") {
        showMsg(context, "Admin login successful");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Adminallscreen()),
        );
        return;
      }

      // -------------------------------
      // FIREBASE AUTH
      // -------------------------------
      UserCredential userCred =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCred.user!.uid;

      // -------------------------------
      // HOSPITAL CHECK
      // -------------------------------
      DocumentSnapshot hospitalSnap =
          await _firestore.collection("hospitals").doc(uid).get();

      if (hospitalSnap.exists) {
        String status = hospitalSnap.get("status");

        if (status == "approved") {
          showMsg(context, "Hospital login successful");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Hospitalallscreen()),
          );
          return;
        } else {
          showMsg(context, "Hospital status: $status");
          return;
        }
      }

      // -------------------------------
      // DOCTOR CHECK
      // -------------------------------
      DocumentSnapshot doctorSnap =
          await _firestore.collection("doctors").doc(uid).get();

      if (doctorSnap.exists) {
        String status = doctorSnap.get("status");

        if (status == "approved") {
          showMsg(context, "Doctor login successful");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Hospitalallscreen()),
          );
          return;
        } else {
          showMsg(context, "Doctor status: $status");
          return;
        }
      }

      // -------------------------------
      // NO ROLE
      // -------------------------------
      showMsg(context, "No hospital or doctor record found");

    } on FirebaseAuthException catch (e) {
      showMsg(context, e.message ?? "Login failed");
    } catch (e) {
      showMsg(context, "Something went wrong");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
