import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/model/model.dart';
import 'package:http/http.dart' as http;

class HospitalController extends ChangeNotifier {
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Approved hospitals (MODEL BASED)
  List<HospitalModel> approvedHospitals = [];

  /// ✅ Hospital-wise doctors
  List<HealthcareModel> doctors = [];

  // ==========================
  // CLOUDINARY CONFIG
  // ==========================
  static const String _cloudName = "dc0ny45w9";
  static const String _uploadPreset = "hospital";

  // ==========================
  // IMAGE UPLOAD
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
          filename: "image.jpg",
        ),
      );

    final response = await request.send();
    final data = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode != 200) {
      throw Exception("Image upload failed");
    }

    return data['secure_url'];
  }

  // ==========================
  // ✅ REGISTER HOSPITAL (MODEL BASED)
  // ==========================
  Future<void> registerHospital({
    required HospitalModel hospital,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      /// 🔐 Firebase Auth
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: hospital.email,
        password: password,
      );

      /// 🔁 Attach UID
      final model = hospital.copyWith(
        uid: cred.user!.uid,
        isApproved: false,
        createdAt: DateTime.now(),
      );

      /// 🏥 Save to Firestore
      await _firestore
          .collection("hospitals")
          .doc(model.uid)
          .set(model.toMap());

      _showMsg(context, "Hospital registered. Waiting for approval");
      Navigator.pop(context);
    } catch (e) {
      _showMsg(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // ✅ FETCH APPROVED HOSPITALS
  // ==========================
  Future<void> fetchApprovedHospitals() async {
    final snap = await _firestore
        .collection("hospitals")
        .where("isApproved", isEqualTo: true)
        .get();

    approvedHospitals = snap.docs
        .map((e) => HospitalModel.fromFirestore(e.data(), e.id))
        .toList();

    notifyListeners();
  }
  Stream<HospitalModel?> getCurrentHospitalStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);

    final uid = user.uid;

    return _firestore
        .collection('hospitals')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return HospitalModel.fromFirestore(doc.data()!, doc.id);
    });
  }


  // ==========================
  // ✅ REGISTER DOCTOR (MODEL BASED)
  // ==========================
  Future<void> registerDoctor({
    required HealthcareModel doctor,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: doctor.email,
        password: password,
      );

      final model = doctor.copyWith(
        uid: cred.user!.uid,
        isApproved: false,
      );

      await _firestore
          .collection("doctors")
          .doc(model.uid)
          .set(model.toMap());

      _showMsg(context, "Doctor registered. Waiting for approval");
      Navigator.pop(context);
    } catch (e) {
      _showMsg(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // ✅ FETCH PENDING DOCTORS (HOSPITAL BASED)
  // ==========================
  Future<void> fetchPendingDoctors(String hospitalName) async {
    isLoading = true;
    notifyListeners();

    final snap = await _firestore
        .collection("doctors")
        .where("hospitalName", isEqualTo: hospitalName)
        .where("isApproved", isEqualTo: false)
        .get();

    doctors = snap.docs
        .map((e) => HealthcareModel.fromFirestore(e.data(), e.id))
        .toList();

    isLoading = false;
    notifyListeners();
  }

  // ==========================
  // ✅ APPROVE DOCTOR
  // ==========================
  Future<void> approveDoctor(String uid) async {
    await _firestore
        .collection("doctors")
        .doc(uid)
        .update({"isApproved": true});

    doctors.removeWhere((e) => e.uid == uid);
    notifyListeners();
  }

  // ==========================
  // SNACKBAR
  // ==========================
  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
