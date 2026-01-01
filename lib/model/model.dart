import 'package:cloud_firestore/cloud_firestore.dart';

class HealthcareModel {
  final String uid;
  final String name;
  final String specialization;
  final String doctorExperience;
  final String contactNumber;
  final String email;
  final String consultationTime;
  final String consultationFee;
  final String hospitalName;
  final List<String> availableDays;
  final String image;
  final bool isApproved;

  HealthcareModel({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.doctorExperience,
    required this.contactNumber,
    required this.email,
    required this.consultationTime,
    required this.consultationFee,
    required this.hospitalName,
    required this.availableDays,
    required this.image,
    required this.isApproved,
  });

  // ==========================
  // 🔥 COPY WITH (FIX)
  // ==========================
  HealthcareModel copyWith({
    String? uid,
    String? name,
    String? specialization,
    String? doctorExperience,
    String? contactNumber,
    String? email,
    String? consultationTime,
    String? consultationFee,
    String? hospitalName,
    List<String>? availableDays,
    String? image,
    bool? isApproved,
  }) {
    return HealthcareModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      doctorExperience: doctorExperience ?? this.doctorExperience,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      consultationTime: consultationTime ?? this.consultationTime,
      consultationFee: consultationFee ?? this.consultationFee,
      hospitalName: hospitalName ?? this.hospitalName,
      availableDays: availableDays ?? this.availableDays,
      image: image ?? this.image,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  // ==========================
  // FIRESTORE MAP
  // ==========================
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "specialization": specialization,
      "doctorExperience": doctorExperience,
      "contactNumber": contactNumber,
      "email": email,
      "consultationTime": consultationTime,
      "consultationFee": consultationFee,
      "hospitalName": hospitalName,
      "availableDays": availableDays,
      "image": image,
      "isApproved": isApproved,
    };
  }

  factory HealthcareModel.fromFirestore(
      Map<String, dynamic> map, String uid) {
    return HealthcareModel(
      uid: uid,
      name: map["name"],
      specialization: map["specialization"],
      doctorExperience: map["doctorExperience"],
      contactNumber: map["contactNumber"],
      email: map["email"],
      consultationTime: map["consultationTime"],
      consultationFee: map["consultationFee"],
      hospitalName: map["hospitalName"],
      availableDays: List<String>.from(map["availableDays"]),
      image: map["image"] ?? "",
      isApproved: map["isApproved"] ?? false,
    );
  }
}
/// 🏥 HOSPITAL MODEL
class HospitalModel {
  final String uid;
  final String hospitalName;
  final String location;
  final String contactNumber;
  final String email;
  final String description;
  final String image;
  final bool isApproved;
  final DateTime createdAt;

  HospitalModel({
    required this.uid,
    required this.hospitalName,
    required this.location,
    required this.contactNumber,
    required this.email,
    required this.description,
    required this.image,
    required this.isApproved,
    required this.createdAt,
  });

  // ==========================
  // 🔁 COPY WITH
  // ==========================
  HospitalModel copyWith({
    String? uid,
    String? hospitalName,
    String? location,
    String? contactNumber,
    String? email,
    String? description,
    String? image,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return HospitalModel(
      uid: uid ?? this.uid,
      hospitalName: hospitalName ?? this.hospitalName,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      description: description ?? this.description,
      image: image ?? this.image,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ==========================
  // 🔁 MODEL → FIRESTORE
  // ==========================
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "hospitalName": hospitalName,
      "location": location,
      "contactNumber": contactNumber,
      "email": email,
      "description": description,
      "image": image,
      "isApproved": isApproved,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  // ==========================
  // 🔁 FIRESTORE → MODEL
  // ==========================
  factory HospitalModel.fromFirestore(
      Map<String, dynamic> map, String docId) {
    return HospitalModel(
      uid: docId,
      hospitalName: map["hospitalName"] ?? "Unknown Hospital",
      location: map["location"] ?? "Unknown Location",
      contactNumber: map["contactNumber"] ?? "N/A",
      email: map["email"] ?? "N/A",
      description: map["description"] ?? "No description",
      image: map["image"] ?? "",
      isApproved: map["isApproved"] ?? false,
      createdAt: map["createdAt"] != null ? (map["createdAt"] as Timestamp).toDate() : DateTime.now(),
    );
  }
}


/// APP USER MODEL


class AppUserModel {
  final String uid;
  final String username;
  final String email;
  final String phoneNumber;
  final String location;
  final DateTime createdAt;

  AppUserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.createdAt,
  });

  // ==========================
  // 🔁 COPY WITH (FIX)
  // ==========================
  AppUserModel copyWith({
  String? uid,
  String? username,
  String? email,
  String? phoneNumber,
  String? location,
  DateTime? createdAt,
}) {
  return AppUserModel(
    uid: uid ?? this.uid,
    username: username ?? this.username,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    location: location ?? this.location,
    createdAt: createdAt ?? this.createdAt,
  );
}


  // ==========================
  // 🔁 MODEL → FIRESTORE
  // ==========================
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
      "email": email,
      "phone": phoneNumber,
      "location": location,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  // ==========================
  // 🔁 FIRESTORE → MODEL
  // ==========================
  factory AppUserModel.fromFirestore(
      Map<String, dynamic> map, String uid) {
    return AppUserModel(
      uid: uid,
      username: map["username"],
      email: map["email"],
      phoneNumber: map["phone"],
      location: map["location"],
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }
}
