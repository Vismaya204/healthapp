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
  TextEditingController doctorName = TextEditingController();
  TextEditingController specialization = TextEditingController();
  TextEditingController experience = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController availableDays = TextEditingController();
  TextEditingController consultationTime = TextEditingController();
  TextEditingController consultationFee = TextEditingController();
  TextEditingController hospitalName = TextEditingController();

  HospitalModel? selectedHospital;

  Uint8List? profileImage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HospitalController>().fetchApprovedHospitals();
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        profileImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Doctor Registration",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// ✅ PROFILE IMAGE
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue.shade100,
                backgroundImage:
                    profileImage != null ? MemoryImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Choose Profile Image"),

            const SizedBox(height: 20),

            /// 🔽 ALL YOUR EXISTING FIELDS (UNCHANGED)
            TextFormField(
              controller: doctorName,
              decoration: InputDecoration(
                hintText: "Doctor Name",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: specialization,
              decoration: InputDecoration(
                hintText: "Specialization",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: experience,
              decoration: InputDecoration(
                hintText: "Experience",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: contactNumber,
              decoration: InputDecoration(
                hintText: "Contact Number",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: email,
              decoration: InputDecoration(
                hintText: "Email",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: password,
              decoration: InputDecoration(
                hintText: "Password",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: availableDays,
              decoration: InputDecoration(
                hintText: "Available Days",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: consultationTime,
              decoration: InputDecoration(
                hintText: "Consultation Time",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: consultationFee,
              decoration: InputDecoration(
                hintText: "Consultation Fee",
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder:
                    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),

            /// 🏥 HOSPITAL DROPDOWN
            Consumer<HospitalController>(
              builder: (context, controller, _) {
                return DropdownButtonFormField<HospitalModel>(
  value: selectedHospital,
  decoration: const InputDecoration(
    labelText: "Select Hospital",
    border: OutlineInputBorder(),
  ),
  items: controller.approvedHospitals.map((hospital) {
    return DropdownMenuItem(
      value: hospital,
      child: Text(hospital.hospitalName),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedHospital = value;
    });
  },
  validator: (value) =>
      value == null ? "Please select hospital" : null,
);


              },
            ),

            const SizedBox(height: 20),

            /// ✅ SIGN UP BUTTON
            Consumer<HospitalController>(
              builder: (context, controller, _) {
                return SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  onPressed: controller.isLoading
    ? null
    : () async {
        // 🔴 BASIC VALIDATION
        if (doctorName.text.trim().isEmpty ||
            specialization.text.trim().isEmpty ||
            experience.text.trim().isEmpty ||
            contactNumber.text.trim().isEmpty ||
            email.text.trim().isEmpty ||
            password.text.trim().isEmpty ||
            consultationTime.text.trim().isEmpty ||
            consultationFee.text.trim().isEmpty ||
            availableDays.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all fields")),
          );
          return;
        }

        if (selectedHospital == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select hospital")),
          );
          return;
        }

        if (profileImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select profile image")),
          );
          return;
        }

        final controller = context.read<HospitalController>();

        // 🔹 Upload image
        final imageUrl =
            await controller.uploadToCloudinary(profileImage!);

        // 🔹 Create Doctor MODEL
        final doctor = HealthcareModel(
          uid: "", // replaced after auth
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

        // 🔹 Register Doctor
        await controller.registerDoctor(
          doctor: doctor,
          password: password.text.trim(),
          context: context,
        );
      },
child: Text("Sign Up"),

                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
