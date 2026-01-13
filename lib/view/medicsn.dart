import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class Medisin extends StatefulWidget {
  final String hospitalId;
  const Medisin({super.key, required this.hospitalId});

  @override
  State<Medisin> createState() => _MedisinState();
}

class _MedisinState extends State<Medisin> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();
  final descController = TextEditingController();

  Uint8List? selectedImageBytes;
  bool loading = false;
  bool isAvailable = true;

  final String cloudName = "dc0ny45w9";
  final String uploadPreset = "hospital";

  /// UPLOAD IMAGE
  Future<String?> uploadToCloudinary(Uint8List bytes) async {
    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'medicine.jpg',
      ));

    final response = await request.send();
    final res = await response.stream.bytesToString();
    return json.decode(res)['secure_url'];
  }

  /// ADD / EDIT DIALOG
  void openMedicineDialog({DocumentSnapshot? doc}) {
    final isEdit = doc != null;

    if (isEdit) {
      nameController.text = doc['name'];
      priceController.text = doc['price'];
      qtyController.text = doc['qty'];
      descController.text = doc['description'];
      isAvailable = doc['available'] ?? true;
      selectedImageBytes = null;
    } else {
      nameController.clear();
      priceController.clear();
      qtyController.clear();
      descController.clear();
      isAvailable = true;
      selectedImageBytes = null;
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          Future<void> pickImage() async {
            final picked =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (picked != null) {
              final bytes = await picked.readAsBytes();
              setDialogState(() => selectedImageBytes = bytes);
            }
          }

          Future<void> saveMedicine() async {
            if (!formKey.currentState!.validate()) return;

            setDialogState(() => loading = true);

            String imageUrl = isEdit ? doc!['imageUrl'] ?? "" : "";

            if (selectedImageBytes != null) {
              imageUrl =
                  await uploadToCloudinary(selectedImageBytes!) ?? imageUrl;
            }

            final data = {
              "name": nameController.text.trim(),
              "price": priceController.text.trim(),
              "qty": qtyController.text.trim(),
              "description": descController.text.trim(),
              "imageUrl": imageUrl,
              "available": isAvailable,
              "updatedAt": FieldValue.serverTimestamp(),
            };

            final ref = FirebaseFirestore.instance
                .collection('hospitals')
                .doc(widget.hospitalId)
                .collection('medicines');

            isEdit ? await ref.doc(doc!.id).update(data) : await ref.add(data);

            if (!mounted) return;
            Navigator.pop(context);
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEdit ? "Edit Medicine" : "Add Medicine"),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.teal.shade100,
                        backgroundImage: selectedImageBytes != null
                            ? MemoryImage(selectedImageBytes!)
                            : (isEdit && doc!['imageUrl'] != "")
                                ? NetworkImage(doc['imageUrl'])
                                : null,
                        child: selectedImageBytes == null &&
                                (!isEdit || doc!['imageUrl'] == "")
                            ? const Icon(Icons.camera_alt)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _field("Medicine Name", nameController),
                    _field("Price", priceController,
                        keyboard: TextInputType.number),
                    _field("Quantity", qtyController,
                        keyboard: TextInputType.number),
                    _field("Description", descController, maxLines: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Availability"),
                        Switch(
                          value: isAvailable,
                          onChanged: (v) =>
                              setDialogState(() => isAvailable = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: loading ? null : saveMedicine,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }

  /// MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicines")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openMedicineDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospitals')
            .doc(widget.hospitalId)
            .collection('medicines')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final meds = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: meds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final doc = meds[index];
              final available = doc['available'] ?? true;

              return Stack(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: doc['imageUrl'] != ""
                                ? NetworkImage(doc['imageUrl'])
                                : null,
                            child: doc['imageUrl'] == ""
                                ? const Icon(Icons.medication)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(doc['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("₹${doc['price']} • Qty: ${doc['qty']}"),
                        ],
                      ),
                    ),
                  ),

                  /// EDIT BUTTON
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => openMedicineDialog(doc: doc),
                    ),
                  ),

                  /// STATUS BADGE
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: available ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        available ? "Available" : "Unavailable",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
