import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/model/model.dart';

class HospitalController extends ChangeNotifier {
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerDoctor({
    required String name,
    required String specialization,
    required String doctorExperience,
    required String contactNumber,
    required String email,
    required String password,
    required String consultationTime,
    required String consultationFee,
    required String hospitalName,
    required String availableDaysText,
    required BuildContext context,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMsg(context, "All required fields must be filled");
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
        password: "",
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

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
