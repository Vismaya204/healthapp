import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalCreateEmergencyScreen extends StatelessWidget {
  final String hospitalId;

  const HospitalCreateEmergencyScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context) {
    final emergencyRef = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('hospital_emergencies');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Hospital Emergency Management",
          style: TextStyle(color: Colors.white),
        ),
      ),

      /// ================= LIST =================
      body: StreamBuilder<QuerySnapshot>(
        stream: emergencyRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No emergencies added"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              final bool ambulanceAvailable =
                  data['ambulanceAvailable'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['emergencyTitle'] ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("Type: ${data['emergencyType']}"),
                      Text("Doctor: ${data['doctorOnDuty']}"),
                      Text("Beds Available: ${data['availableBeds']}"),
                      Text("Hospital Contact: ${data['contactNumber']}"),
                      const Divider(),

                      /// Ambulance Details
                      Text(
                        "Ambulance Available: ${ambulanceAvailable ? 'Yes' : 'No'}",
                        style: TextStyle(
                          color: ambulanceAvailable
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ambulanceAvailable) ...[
                        Text(
                            "Ambulances: ${data['ambulanceCount'] ?? 0}"),
                        Text(
                            "Ambulance Contact: ${data['ambulanceContact'] ?? ''}"),
                      ],

                      const Divider(),
                      Text(data['description'] ?? ''),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      /// ================= ADD BUTTON =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () =>
            _showAddEmergencyModal(context, emergencyRef),
      ),
    );
  }

  /// ================= ADD EMERGENCY MODAL =================
  void _showAddEmergencyModal(
    BuildContext context,
    CollectionReference emergencyRef,
  ) {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final bedsCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ambulanceCountCtrl = TextEditingController();
    final ambulanceContactCtrl = TextEditingController();

    String emergencyType = 'General';
    bool ambulanceAvailable = false;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Emergency",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _field(titleCtrl, "Emergency Title"),
                  _field(doctorCtrl, "Doctor On Duty"),
                  _field(contactCtrl, "Hospital Contact Number"),
                  _field(bedsCtrl, "Available Beds", isNumber: true),

                  DropdownButtonFormField(
                    value: emergencyType,
                    items: const [
                      DropdownMenuItem(
                          value: 'General', child: Text("General")),
                      DropdownMenuItem(
                          value: 'Accident', child: Text("Accident")),
                      DropdownMenuItem(
                          value: 'Cardiac', child: Text("Cardiac")),
                      DropdownMenuItem(value: 'ICU', child: Text("ICU")),
                    ],
                    onChanged: (v) => emergencyType = v!,
                    decoration:
                        const InputDecoration(labelText: "Emergency Type"),
                  ),

                  SwitchListTile(
                    title: const Text("Ambulance Available"),
                    value: ambulanceAvailable,
                    onChanged: (v) =>
                        setModalState(() => ambulanceAvailable = v),
                  ),

                  if (ambulanceAvailable) ...[
                    _field(ambulanceCountCtrl, "Number of Ambulances",
                        isNumber: true),
                    _field(
                        ambulanceContactCtrl, "Ambulance Contact Number"),
                  ],

                  _field(descCtrl, "Description", maxLines: 3),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () async {
                        await emergencyRef.add({
                          'emergencyTitle': titleCtrl.text,
                          'doctorOnDuty': doctorCtrl.text,
                          'contactNumber': contactCtrl.text,
                          'availableBeds':
                              int.tryParse(bedsCtrl.text) ?? 0,
                          'emergencyType': emergencyType,
                          'ambulanceAvailable': ambulanceAvailable,
                          'ambulanceCount': ambulanceAvailable
                              ? int.tryParse(
                                      ambulanceCountCtrl.text) ??
                                  0
                              : 0,
                          'ambulanceContact': ambulanceAvailable
                              ? ambulanceContactCtrl.text
                              : '',
                          'description': descCtrl.text,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context);
                      },
                      child: const Text("Create Emergency"),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
