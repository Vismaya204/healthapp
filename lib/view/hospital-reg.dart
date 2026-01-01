import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/model/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HospitalRegister extends StatefulWidget {
  const HospitalRegister({super.key});

  @override
  State<HospitalRegister> createState() => _HospitalRegisterState();
}

class _HospitalRegisterState extends State<HospitalRegister> {
  final TextEditingController hospitalName = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController description = TextEditingController();

  Uint8List? hospitalImage;
  bool _obscurePassword = true;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => hospitalImage = bytes);
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
            const SizedBox(height: 30),

            Text(
              "Hospital Registration",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Register your hospital to manage healthcare services",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 25),

            /// 🖼 IMAGE PICKER
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                  image: hospitalImage != null
                      ? DecorationImage(
                          image: MemoryImage(hospitalImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hospitalImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 35, color: Colors.blue),
                          const SizedBox(height: 6),
                          const Text("Upload Logo",
                              style: TextStyle(fontSize: 12)),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 25),

            /// FORM FIELDS
            _inputField(
              controller: hospitalName,
              hint: "Hospital Name",
              icon: Icons.business,
            ),

            const SizedBox(height: 15),

            _inputField(
              controller: location,
              hint: "Location",
              icon: Icons.location_on,
            ),

            const SizedBox(height: 15),

            _inputField(
              controller: contactNumber,
              hint: "Contact Number",
              icon: Icons.phone,
              keyboard: TextInputType.phone,
            ),

            const SizedBox(height: 15),

            _inputField(
              controller: email,
              hint: "Email Address",
              icon: Icons.email,
              keyboard: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            /// PASSWORD
            TextFormField(
              controller: password,
              obscureText: _obscurePassword,
              decoration: _passwordDecoration(),
            ),

            const SizedBox(height: 15),

            /// DESCRIPTION
            TextFormField(
              controller: description,
              maxLines: 4,
              decoration: _inputDecoration(
                "Hospital Description",
                Icons.description,
              ),
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        if (hospitalName.text.trim().isEmpty ||
                            location.text.trim().isEmpty ||
                            contactNumber.text.trim().isEmpty ||
                            email.text.trim().isEmpty ||
                            password.text.trim().isEmpty ||
                            description.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")),
                          );
                          return;
                        }

                        if (hospitalImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please upload hospital image")),
                          );
                          return;
                        }

                        try {
                          final imageUrl = await controller
                              .uploadToCloudinary(hospitalImage!);

                          final hospital = HospitalModel(
                            uid: "",
                            hospitalName: hospitalName.text.trim(),
                            location: location.text.trim(),
                            contactNumber: contactNumber.text.trim(),
                            email: email.text.trim(),
                            description: description.text.trim(),
                            image: imageUrl,
                            isApproved: false,
                            createdAt: DateTime.now(),
                          );

                          await controller.registerHospital(
                            hospital: hospital,
                            password: password.text.trim(),
                            context: context,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                child: controller.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register Hospital",
                        style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Trusted Healthcare Partner Registration",
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================
  /// COMMON INPUT FIELD
  /// ==========================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
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
        onPressed: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
      ),
    );
  }
}
