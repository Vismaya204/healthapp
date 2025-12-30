import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
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
                return DropdownButtonFormField<String>(
                  value: hospitalName.text.isEmpty ? null : hospitalName.text,
                  items: controller.approvedHospitals
                      .map(
                        (hospital) => DropdownMenuItem<String>(
                          value: hospital,
                          child: Text(hospital),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      hospitalName.text = value!;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Select Hospital",
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder:
                        const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  ),
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
                        : () {
                            context.read<HospitalController>().registerDoctor(password:password.text ,
                                  name: doctorName.text,
                                  specialization: specialization.text,
                                  doctorExperience: experience.text,
                                  contactNumber: contactNumber.text,
                                  email: email.text,
                                  consultationTime: consultationTime.text,
                                  consultationFee: consultationFee.text,
                                  hospitalName: hospitalName.text,
                                  availableDaysText: availableDays.text,
                                  context: context,
                                );
                          },
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign up"),
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
