import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Doctorspanding extends StatelessWidget {
  final String hospitalName;

  const Doctorspanding({
    super.key,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    final doctorsRef = FirebaseFirestore.instance
        .collection('doctors')
        .where('hospitalName', isEqualTo: hospitalName)
        .where('isApproved', isEqualTo: false);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Pending Doctor Approvals"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: doctorsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final imageUrl = doc['image'];

              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      /// 👨‍⚕️ HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage:
                                imageUrl != null && imageUrl != ""
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child: imageUrl == null || imageUrl == ""
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 30,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  doc['specialization'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(),

                      /// 📋 DETAILS
                      _infoRow(
                          "Experience", doc['doctorExperience'] ?? ''),
                      _infoRow(
                          "Consultation Fee", doc['consultationFee'] ?? ''),
                      _infoRow(
                          "Consultation Time", doc['consultationTime'] ?? ''),
                      _infoRow("Contact", doc['contactNumber'] ?? ''),

                      const SizedBox(height: 14),

                      /// ✅ APPROVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "Approve Doctor",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('doctors')
                                .doc(doc.id)
                                .update({"isApproved": true});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Doctor approved successfully"),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ==========================
  /// INFO ROW
  /// ==========================
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================
  /// EMPTY STATE
  /// ==========================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty,
              size: 80, color: Colors.blue.shade200),
          const SizedBox(height: 12),
          const Text(
            "No pending doctor approvals",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
