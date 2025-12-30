import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HospitalController extends ChangeNotifier {
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ REQUIRED FOR DROPDOWN
  List<String> approvedHospitals = [];

  // ==========================
  // CLOUDINARY CONFIG
  // ==========================
  static const String _cloudName = "dc0ny45w9";
  static const String _uploadPreset = "hospital";

  // ==========================
  // UPLOAD IMAGE TO CLOUDINARY
  // ==========================
  Future<String> uploadToCloudinary(Uint8List imageBytes) async {
    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: "hospital.jpg",
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode != 200) {
      throw Exception("Image upload failed");
    }

    return data['secure_url'];
  }

  // ==========================
  // FETCH APPROVED HOSPITALS
  // ==========================
  Future<void> fetchApprovedHospitals() async {
    try {
      final snap = await _firestore
          .collection("hospitals")
          .where("isApproved", isEqualTo: true)
          .get();

      approvedHospitals =
          snap.docs.map((doc) => doc["hospitalName"] as String).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching hospitals: $e");
    }
  }

  // ==========================
  // DOCTOR REGISTRATION
  // ==========================
 Future<void> registerDoctor({
  required String name,
  required String specialization,
  required String doctorExperience,
  required String contactNumber,
  required String email,
  required String password, // ADD THIS
  required String consultationTime,
  required String consultationFee,
  required String hospitalName,
  required String availableDaysText,
  required BuildContext context,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    // 1️⃣ AUTH USER
    final userCred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2️⃣ FIRESTORE
    await _firestore.collection("doctors").doc(userCred.user!.uid).set({
      "uid": userCred.user!.uid,
      "name": name,
      "specialization": specialization,
      "doctorExperience": doctorExperience,
      "contactNumber": contactNumber,
      "email": email,
      "consultationTime": consultationTime,
      "consultationFee": consultationFee,
      "hospitalName": hospitalName,
      "availableDays": availableDaysText.split(","),
      "isApproved": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    _showMsg(context, "Doctor Registered. Wait for approval");
    Navigator.pop(context);
  } catch (e) {
    _showMsg(context, e.toString());
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  // ==========================
  // HOSPITAL REGISTRATION
  // ==========================
  Future<void> registerHospital({
  required String hospitalName,
  required String location,
  required String contactNumber,
  required String email,
  required String password, // ADD THIS
  required String description,
  required Uint8List? imageBytes,
  required BuildContext context,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    // 1️⃣ CREATE AUTH USER
    final userCred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String imageUrl = "";
    if (imageBytes != null) {
      imageUrl = await uploadToCloudinary(imageBytes);
    }

    // 2️⃣ SAVE IN FIRESTORE
    await _firestore.collection("hospitals").doc(userCred.user!.uid).set({
      "uid": userCred.user!.uid,
      "hospitalName": hospitalName,
      "location": location,
      "contactNumber": contactNumber,
      "email": email,
      "description": description,
      "image": imageUrl,
      "isApproved": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    _showMsg(context, "Hospital Registered. Wait for approval");
    Navigator.pop(context);
  } catch (e) {
    _showMsg(context, e.toString());
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  // ==========================
  // COMMON SNACKBAR
  // ==========================
  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
