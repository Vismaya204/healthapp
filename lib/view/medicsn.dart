import 'dart:typed_data';
import 'dart:convert'; // for base64
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medisin extends StatefulWidget {
  const Medisin({super.key});

  @override
  State<Medisin> createState() => _MedisinState();
}

class _MedisinState extends State<Medisin> {
  final List<Map<String, dynamic>> medicines = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  /// ================= LOAD MEDICINES =================
  void loadMedicines() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .get();

    final meds = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      // Decode image from Base64
      if (data['image'] != null && data['image'] != "") {
        data['imageBytes'] = base64Decode(data['image']);
      }

      return data;
    }).toList();

    setState(() {
      medicines.clear();
      medicines.addAll(meds);
    });
  }

  /// ================= SAVE MEDICINE =================
  Future<void> saveMedicine(Map<String, dynamic> medData, {String? docId}) async {
    if (docId == null) {
      await FirebaseFirestore.instance.collection('medicines').add(medData);
    } else {
      await FirebaseFirestore.instance
          .collection('medicines')
          .doc(docId)
          .update(medData);
    }
  }

  /// ================= ADD / EDIT MEDICINE =================
  void _openMedicineDialog({Map<String, dynamic>? editData, int? index}) {
    if (editData != null) {
      nameController.text = editData["name"];
      priceController.text = editData["price"];
      qtyController.text = editData["qty"];
      selectedImageBytes = editData["imageBytes"];
    } else {
      nameController.clear();
      priceController.clear();
      qtyController.clear();
      selectedImageBytes = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                setDialogState(() {
                  selectedImageBytes = bytes;
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(editData == null ? "Add Medicine" : "Edit Medicine"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: selectedImageBytes != null
                            ? MemoryImage(selectedImageBytes!)
                            : null,
                        child: selectedImageBytes == null
                            ? const Icon(Icons.camera_alt,
                                size: 30, color: Colors.blue)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _inputField("Medicine Name", nameController),
                    _inputField("Price", priceController,
                        keyboard: TextInputType.number),
                    _inputField("Quantity", qtyController,
                        keyboard: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        qtyController.text.isEmpty) {
                      return;
                    }

                    // Convert image to Base64 for Firestore
                    String imageBase64 = "";
                    if (selectedImageBytes != null) {
                      imageBase64 = base64Encode(selectedImageBytes!);
                    }

                    final data = {
                      "name": nameController.text,
                      "price": priceController.text,
                      "qty": qtyController.text,
                      "image": imageBase64,
                      "createdAt": FieldValue.serverTimestamp(),
                    };

                    if (editData == null) {
                      await saveMedicine(data);
                      setState(() {
                        medicines.add({
                          ...data,
                          "imageBytes": selectedImageBytes
                        });
                      });
                    } else {
                      final docId = editData["id"];
                      await saveMedicine(data, docId: docId);
                      setState(() {
                        medicines[index!] = {
                          ...data,
                          "id": docId,
                          "imageBytes": selectedImageBytes
                        };
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: Text(editData == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Medicines"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _openMedicineDialog(),
        child: const Icon(Icons.add),
      ),
      body: medicines.isEmpty
          ? const Center(
              child: Text("No medicines added",
                  style: TextStyle(color: Colors.grey)),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicines.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final med = medicines[index];

                return GestureDetector(
                  onTap: () {
                    _openMedicineDialog(editData: med, index: index);
                  },
                  child: Stack(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: med["imageBytes"] != null
                                    ? MemoryImage(med["imageBytes"])
                                    : null,
                                child: med["imageBytes"] == null
                                    ? const Icon(Icons.medication,
                                        size: 30, color: Colors.blue)
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                med["name"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text("₹${med["price"]}"),
                              Text("Qty: ${med["qty"]}"),
                            ],
                          ),
                        ),
                      ),

                      /// DELETE
                      Positioned(
                        top: 6,
                        left: 6,
                        child: InkWell(
                          onTap: () async {
                            final docId = med["id"];
                            await FirebaseFirestore.instance
                                .collection('medicines')
                                .doc(docId)
                                .delete();
                            setState(() {
                              medicines.removeAt(index);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.delete,
                                size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// ================= INPUT FIELD =================
  Widget _inputField(String hint, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
