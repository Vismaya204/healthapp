import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/model/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DoctorReg extends StatefulWidget {
  const DoctorReg({super.key});

  @override
  State<DoctorReg> createState() => _DoctorRegState();
}

class _DoctorRegState extends State<DoctorReg> {
  final TextEditingController doctorName = TextEditingController();
  final TextEditingController specialization = TextEditingController();
  final TextEditingController experience = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController availableDays = TextEditingController();
  final TextEditingController consultationTime = TextEditingController();
  final TextEditingController consultationFee = TextEditingController();

  HospitalModel? selectedHospital;
  Uint8List? profileImage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HospitalController>().fetchApprovedHospitals();
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      profileImage = await image.readAsBytes();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HospitalController>();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Doctor Registration",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Join a hospital & manage your appointments",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 25),

            /// 👤 PROFILE IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                  image: profileImage != null
                      ? DecorationImage(
                          image: MemoryImage(profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt,
                              size: 35, color: Colors.blue),
                          SizedBox(height: 6),
                          Text("Upload Photo",
                              style: TextStyle(fontSize: 12)),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 25),

            /// FORM FIELDS
            _inputField(doctorName, "Doctor Name", Icons.person),
            _gap(),
            _inputField(specialization, "Specialization", Icons.work),
            _gap(),
            _inputField(experience, "Experience (years)", Icons.timeline),
            _gap(),
            _inputField(contactNumber, "Contact Number", Icons.phone,
                keyboard: TextInputType.phone),
            _gap(),
            _inputField(email, "Email Address", Icons.email,
                keyboard: TextInputType.emailAddress),
            _gap(),

            /// PASSWORD
            TextFormField(
              controller: password,
              obscureText: _obscurePassword,
              decoration: _passwordDecoration(),
            ),

            _gap(),
            _inputField(
                availableDays, "Available Days (Mon, Tue)", Icons.date_range),
            _gap(),
            _inputField(
                consultationTime, "Consultation Time", Icons.schedule),
            _gap(),
            _inputField(
                consultationFee, "Consultation Fee", Icons.currency_rupee),
            _gap(),

            /// 🏥 HOSPITAL DROPDOWN
            DropdownButtonFormField<HospitalModel>(
              value: selectedHospital,
              decoration: _inputDecoration(
                  "Select Hospital", Icons.local_hospital),
              items: controller.approvedHospitals.map((hospital) {
                return DropdownMenuItem(
                  value: hospital,
                  child: Text(hospital.hospitalName),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedHospital = value;
              }),
            ),

            const SizedBox(height: 30),

            /// SIGNUP BUTTON
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        if (doctorName.text.isEmpty ||
                            specialization.text.isEmpty ||
                            experience.text.isEmpty ||
                            contactNumber.text.isEmpty ||
                            email.text.isEmpty ||
                            password.text.isEmpty ||
                            consultationTime.text.isEmpty ||
                            consultationFee.text.isEmpty ||
                            availableDays.text.isEmpty ||
                            selectedHospital == null ||
                            profileImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")),
                          );
                          return;
                        }

                        final imageUrl = await controller
                            .uploadToCloudinary(profileImage!);

                        final doctor = HealthcareModel(
                          uid: "",
                          name: doctorName.text.trim(),
                          specialization: specialization.text.trim(),
                          doctorExperience: experience.text.trim(),
                          contactNumber: contactNumber.text.trim(),
                          email: email.text.trim(),
                          consultationTime: consultationTime.text.trim(),
                          consultationFee: consultationFee.text.trim(),
                          hospitalName: selectedHospital!.hospitalName,
                          availableDays: availableDays.text
                              .split(",")
                              .map((e) => e.trim())
                              .toList(),
                          image: imageUrl,
                          isApproved: false,
                        );

                        await controller.registerDoctor(
                          doctor: doctor,
                          password: password.text.trim(),
                          context: context,
                        );
                      },
                child: controller.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register Doctor",
                        style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Secure doctor onboarding system",
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================
  /// UI HELPERS
  /// ==========================
  Widget _gap() => const SizedBox(height: 15);

  Widget _inputField(TextEditingController controller, String hint,
      IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _inputDecoration(hint, icon),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  InputDecoration _passwordDecoration() {
    return _inputDecoration("Password", Icons.lock).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: Colors.blue,
        ),
        onPressed: () =>
            setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }
}
