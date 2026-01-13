import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// ===================================================
/// DOCTOR CATEGORIES SCREEN
/// ===================================================
class DoctorCategoriesScreen extends StatelessWidget {
  final String hospitalName;

  const DoctorCategoriesScreen({
    super.key,
    required this.hospitalName,
  });

  final List<Map<String, dynamic>> categories = const [
    {"name": "Cardiologist", "icon": Icons.favorite, "color": Colors.red},
    {"name": "Dentist", "icon": Icons.medical_services, "color": Colors.blue},
    {"name": "Neurologist", "icon": Icons.psychology, "color": Colors.purple},
    {"name": "Dermatologist", "icon": Icons.face, "color": Colors.orange},
    {"name": "Pediatrician", "icon": Icons.child_care, "color": Colors.green},
    {"name": "Gynaecology", "icon": Icons.female, "color": Colors.pink},
    {"name": "All", "icon": Icons.medical_services, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Categories"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue.shade50,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorListScreen(
                    category: category['name'],
                    hospitalName: hospitalName,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category['icon'],
                      size: 40, color: category['color']),
                  const SizedBox(height: 10),
                  Text(
                    category['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ===================================================
/// DOCTOR LIST SCREEN (UPDATE + DELETE)
/// ===================================================
class DoctorListScreen extends StatelessWidget {
  final String category;
  final String hospitalName;

  const DoctorListScreen({
    super.key,
    required this.category,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('doctors')
        .where('isApproved', isEqualTo: true)
        .where('hospitalName', isEqualTo: hospitalName);

    if (category != "All") {
      query = query.where('specialization', isEqualTo: category);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$category Doctors"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue.shade50,
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _doctorCard(context, snapshot.data!.docs[index]);
            },
          );
        },
      ),
    );
  }

  /// ===============================
  /// DOCTOR CARD
  /// ===============================
  Widget _doctorCard(
      BuildContext context, QueryDocumentSnapshot doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(doctor['image']),
        ),
        title: Text(
          doctor['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor['specialization']),
            Text("Experience: ${doctor['doctorExperience']} years"),
            Text(
              "Fee: ₹${doctor['consultationFee']}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),

        /// ✏️ UPDATE + 🗑 DELETE
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateDoctorScreen(
                      doctorId: doctor.id,
                      doctorData:
                          doctor.data() as Map<String, dynamic>,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDoctorDetails(context, doctor);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// DOCTOR DETAILS + DELETE
  /// ===============================
  void _showDoctorDetails(
      BuildContext context, QueryDocumentSnapshot doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Doctor Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(doctor['image']),
              ),
            ),
            const SizedBox(height: 10),
            Text("Name: ${doctor['name']}"),
            Text("Specialization: ${doctor['specialization']}"),
            Text("Experience: ${doctor['doctorExperience']} years"),
            Text("Fee: ₹${doctor['consultationFee']}"),
            const SizedBox(height: 12),
            const Text(
              "⚠ This action cannot be undone",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(doctor.id)
                  .delete();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Doctor deleted successfully")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No doctors found",
        style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// ===================================================
/// UPDATE DOCTOR SCREEN (PLACEHOLDER)
/// ===================================================

class UpdateDoctorScreen extends StatefulWidget {
  final String doctorId;
  final Map<String, dynamic> doctorData;

  const UpdateDoctorScreen({
    super.key,
    required this.doctorId,
    required this.doctorData,
  });

  @override
  State<UpdateDoctorScreen> createState() => _UpdateDoctorScreenState();
}

class _UpdateDoctorScreenState extends State<UpdateDoctorScreen> {
  late TextEditingController nameController;
  late TextEditingController specializationController;
  late TextEditingController experienceController;
  late TextEditingController feeController;

  File? selectedImage;
  String imageUrl = "";

  bool isLoading = false;

  /// 🔹 CLOUDINARY CONFIG
  static const String cloudName = "dc0ny45w9";
  static const String uploadPreset = "hospital";

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.doctorData['name']);
    specializationController =
        TextEditingController(text: widget.doctorData['specialization']);
    experienceController =
        TextEditingController(
            text: widget.doctorData['doctorExperience'].toString());
    feeController =
        TextEditingController(
            text: widget.doctorData['consultationFee'].toString());

    imageUrl = widget.doctorData['image'];
  }

  /// ===============================
  /// PICK IMAGE
  /// ===============================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  /// ===============================
  /// UPLOAD TO CLOUDINARY
  /// ===============================
  Future<String> _uploadToCloudinary(File imageFile) async {
    final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(resBody);
      return data['secure_url'];
    } else {
      throw "Image upload failed";
    }
  }

  /// ===============================
  /// UPDATE DOCTOR (NO VALIDATION)
  /// ===============================
  Future<void> _updateDoctor() async {
    setState(() => isLoading = true);

    try {
      String updatedImageUrl = imageUrl;

      if (selectedImage != null) {
        updatedImageUrl = await _uploadToCloudinary(selectedImage!);
      }

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .update({
        'name': nameController.text.trim(),
        'specialization': specializationController.text.trim(),
        'doctorExperience':
            experienceController.text.trim(),
        'consultationFee':
            double.tryParse(feeController.text) ?? 0,
        'image': updatedImageUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Doctor"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// PROFILE IMAGE
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : NetworkImage(imageUrl) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _inputField("Doctor Name", nameController),
            _inputField("Specialization", specializationController),
            _inputField("Experience (years)", experienceController,
               ),
            _inputField("Consultation Fee", feeController,
                isNumber: true),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : _updateDoctor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Update Doctor",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// INPUT FIELD (NO VALIDATOR)
  /// ===============================
  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
