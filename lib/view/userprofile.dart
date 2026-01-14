import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/userallscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Userprofile extends StatelessWidget {
  const Userprofile({super.key});

  // 🔴 CHANGE THESE
  static const String cloudName = "YOUR_CLOUD_NAME";
  static const String uploadPreset = "YOUR_UPLOAD_PRESET";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return WillPopScope(onWillPop: () async{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Userallscreen(),));return false;
    },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Profile"),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("User data not found"));
            }
      
            final data = snapshot.data!.data() as Map<String, dynamic>;
      
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// PROFILE IMAGE
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: data['profileImage'] != null
                            ? NetworkImage(data['profileImage'])
                            : null,
                        child: data['profileImage'] == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            onPressed: () =>
                                _pickAndUploadImage(context, user.uid),
                          ),
                        ),
                      )
                    ],
                  ),
      
                  const SizedBox(height: 30),
      
                  _profileTile(
                    title: "Username",
                    value: data['username'],
                    onEdit: () => _editField(
                        context, user.uid, "username", data['username']),
                  ),
      
                  _profileTile(
                    title: "Email",
                    value: data['email'],
                  ),
      
                  _profileTile(
                    title: "Phone",
                    value: data['phone'],
                    onEdit: () => _editField(
                        context, user.uid, "phone", data['phone']),
                  ),
      
                  _profileTile(
                    title: "Location",
                    value: data['location'],
                    onEdit: () => _editField(
                        context, user.uid, "location", data['location']),
                  ),
      
                  const SizedBox(height: 30),
      
                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// PROFILE TILE WITH TEXT EDIT BUTTON
  Widget _profileTile({
    required String title,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
            if (onEdit != null)
              TextButton(
                onPressed: onEdit,
                child: const Text("Edit"),
              ),
          ],
        ),
      ),
    );
  }

  /// EDIT FIELD DIALOG
  void _editField(
      BuildContext context, String uid, String field, String oldValue) {
    final controller = TextEditingController(text: oldValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({field: controller.text});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// CLOUDINARY IMAGE UPLOAD
  Future<void> _pickAndUploadImage(
      BuildContext context, String uid) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);

      final imageUrl = data['secure_url'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({"profileImage": imageUrl});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed")),
      );
    }
  }
}
