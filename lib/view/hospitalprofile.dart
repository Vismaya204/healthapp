import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:healthapp/view/registerloginscreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/model/model.dart';

class HospitalProfile extends StatefulWidget {
  const HospitalProfile({super.key});

  @override
  State<HospitalProfile> createState() => _HospitalProfileState();
}

class _HospitalProfileState extends State<HospitalProfile> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  Uint8List? _newImageBytes;

  final ImagePicker _picker = ImagePicker();

  

  /// 📸 PICK IMAGE
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _newImageBytes = bytes);
    }
  }

  /// 💾 SAVE PROFILE
  Future<void> _saveProfile(HospitalModel hospital) async {
    setState(() => _isSaving = true);

    String? imageUrl;

    if (_newImageBytes != null) {
      setState(() => _isUploadingImage = true);

      imageUrl = await context
          .read<HospitalController>()
          .uploadToCloudinary(_newImageBytes!);

      setState(() => _isUploadingImage = false);
    }

    await context.read<HospitalController>().updateHospitalProfile(
          hospitalName: nameController.text.trim(),
          location: locationController.text.trim(),
          email: emailController.text.trim(),
          contactNumber: phoneController.text.trim(),
          description: descriptionController.text.trim(),
          image: imageUrl,
        );

    setState(() {
      _isSaving = false;
      _newImageBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Hospital Profile"),
      ),
      body: StreamBuilder<HospitalModel?>(
        stream:
            context.read<HospitalController>().getCurrentHospitalStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hospital = snapshot.data!;

          if (!_isInitialized) {
            nameController.text = hospital.hospitalName;
            locationController.text = hospital.location;
            emailController.text = hospital.email;
            phoneController.text = hospital.contactNumber;
            descriptionController.text = hospital.description;
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 📸 PROFILE IMAGE
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _newImageBytes != null
                          ? MemoryImage(_newImageBytes!)
                          : hospital.image.isNotEmpty
                              ? NetworkImage(hospital.image)
                              : null,
                      child: hospital.image.isEmpty &&
                              _newImageBytes == null
                          ? const Icon(Icons.local_hospital,
                              size: 50, color: Colors.blue)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_isUploadingImage)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),

                const SizedBox(height: 20),

                _textField("Hospital Name", nameController),
                _textField("Location", locationController),
                _textField("Email", emailController),
                _textField("Contact Number", phoneController),
                _textField(
                  "Description",
                  descriptionController,
                  maxLines: 4,
                ),

                const SizedBox(height: 25),

                /// 💾 SAVE
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () => _saveProfile(hospital),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Profile",
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                ),

                const SizedBox(height: 16),

                /// 🚪 LOGOUT
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style:
                        TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Registerloginscreen(),));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
