import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalAmbulanceScreen extends StatelessWidget {
  final String hospitalId;

  const HospitalAmbulanceScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final ambulanceRef = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('ambulances');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Hospital Ambulances",
            style: TextStyle(color: Colors.white)),
      ),

      /// ================= LIST =================
      body: StreamBuilder<QuerySnapshot>(
        stream: ambulanceRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No ambulances added"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title + Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ambulance: ${data['ambulanceNumber']}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editAmbulance(
                                  context,
                                  ambulanceRef,
                                  doc.id,
                                  data,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteAmbulance(context, ambulanceRef, doc.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Driver Name: ${data['driverName']}"),
                      Text("Driver Phone: ${data['driverPhone']}"),
                      Text("Ambulance Contact: ${data['ambulanceContact']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      /// ================= ADD =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () => _addAmbulance(context, ambulanceRef),
      ),
    );
  }

  /// ================= ADD =================
  void _addAmbulance(BuildContext context, CollectionReference ref) {
    _openBottomSheet(context, ref);
  }

  /// ================= EDIT =================
  void _editAmbulance(
    BuildContext context,
    CollectionReference ref,
    String docId,
    Map<String, dynamic> data,
  ) {
    _openBottomSheet(
      context,
      ref,
      docId: docId,
      existingData: data,
    );
  }

  /// ================= DELETE =================
  void _deleteAmbulance(
      BuildContext context, CollectionReference ref, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Ambulance"),
        content: const Text("Are you sure you want to delete this ambulance?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.doc(docId).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// ================= BOTTOM SHEET (ADD / EDIT) =================
  void _openBottomSheet(
    BuildContext context,
    CollectionReference ref, {
    String? docId,
    Map<String, dynamic>? existingData,
  }) {
    final ambulanceNumberCtrl =
        TextEditingController(text: existingData?['ambulanceNumber']);
    final ambulanceContactCtrl =
        TextEditingController(text: existingData?['ambulanceContact']);
    final driverNameCtrl =
        TextEditingController(text: existingData?['driverName']);
    final driverPhoneCtrl =
        TextEditingController(text: existingData?['driverPhone']);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                docId == null ? "Add Ambulance" : "Edit Ambulance",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _field(ambulanceNumberCtrl, "Ambulance Number"),
              _field(ambulanceContactCtrl, "Ambulance Contact"),
              _field(driverNameCtrl, "Driver Name"),
              _field(driverPhoneCtrl, "Driver Phone", isNumber: true),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final data = {
                      'ambulanceNumber': ambulanceNumberCtrl.text,
                      'ambulanceContact': ambulanceContactCtrl.text,
                      'driverName': driverNameCtrl.text,
                      'driverPhone': driverPhoneCtrl.text,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      await ref.add(data);
                    } else {
                      await ref.doc(docId).update(data);
                    }

                    Navigator.pop(context);
                  },
                  child: Text(docId == null ? "Add" : "Update"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
