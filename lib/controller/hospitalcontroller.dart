import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/model/model.dart';
import 'package:healthapp/view/approvedhospital.dart';
import 'package:http/http.dart' as http;

class HospitalController extends ChangeNotifier {
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================
  // CLOUDINARY CONFIG
  // ==========================
  static const String _cloudName = "dc0ny45w9";
  static const String _uploadPreset = "hospital";

  // ==========================
  // UPLOAD IMAGE TO CLOUDINARY
  // ==========================
  Future<String> uploadToCloudinary(Uint8List imageBytes) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
    );

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
  // DOCTOR REGISTRATION
  // ==========================
  Future<void> registerDoctor({
    required String name,
    required String specialization,
    required String doctorExperience,
    required String contactNumber,
    required String email,
    required String consultationTime,
    required String consultationFee,
    required String hospitalName,
    required String availableDaysText,
    required BuildContext context,
  }) async {
    if (name.isEmpty ||
        specialization.isEmpty ||
        contactNumber.isEmpty ||
        email.isEmpty ||
        consultationTime.isEmpty ||
        consultationFee.isEmpty ||
        hospitalName.isEmpty ||
        availableDaysText.isEmpty) {
      _showMsg(context, "Please fill all required fields");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final doctor = HealthcareModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        specialization: specialization,
        doctorExperience: doctorExperience,
        contactNumber: contactNumber,
        email: email,
        consultationTime: consultationTime,
        consultationFee: consultationFee,
        hospitalName: hospitalName,
        availableDays: availableDaysText.split(","),
        image: "",
      );

      await _firestore.collection("doctors").add(doctor.toMap());

      _showMsg(context, "Doctor Registered Successfully");
    } catch (e) {
      _showMsg(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // HOSPITAL REGISTRATION (WITH IMAGE)
  // ==========================
  Future<void> registerHospital({
    required String hospitalName,
    required String location,
    required String contactNumber,
    required String email,
    required Uint8List? imageBytes,
    required BuildContext context,
  }) async {
    if (hospitalName.isEmpty ||
        location.isEmpty ||
        contactNumber.isEmpty ||
        email.isEmpty) {
      _showMsg(context, "Please fill all required fields");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      String imageUrl = "";

      if (imageBytes != null) {
        imageUrl = await uploadToCloudinary(imageBytes);
      }

      final hospitalData = {
        "hospitalName": hospitalName,
        "location": location,
        "contactNumber": contactNumber,
        "email": email,
        "image": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection("hospitals").add(hospitalData);

      _showMsg(context, "Hospital Registered Successfully");
      Navigator.pop(context);
    } catch (e) {
      _showMsg(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
final FirebaseAuth _auth = FirebaseAuth.instance;


  // COMMON SNACKBAR
  // ==========================
  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
