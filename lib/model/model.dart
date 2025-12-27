class HealthcareModel {
  int id;
  String name;                 // Doctor Name
  String specialization;       // Doctor Specialization
  String doctorExperience;     // Experience
  String contactNumber;
  String email;

  String consultationTime;
  String consultationFee;
  String hospitalName;
  List<String> availableDays;
  String image;                // Profile image URL (future use)

  HealthcareModel({
    required this.id,
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
  });

  /// Convert Model → Map (for API / Firebase)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
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
    };
  }

  /// Convert Map → Model
  factory HealthcareModel.fromMap(Map<String, dynamic> map) {
    return HealthcareModel(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
      doctorExperience: map['doctorExperience'],
      contactNumber: map['contactNumber'],
      email: map['email'],
      consultationTime: map['consultationTime'],
      consultationFee: map['consultationFee'],
      hospitalName: map['hospitalName'],
      availableDays: List<String>.from(map['availableDays']),
      image: map['image'],
    );
  }
}
