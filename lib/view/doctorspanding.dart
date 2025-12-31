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
      appBar: AppBar(
        title: Text('Pending Doctors - $hospitalName'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: doctorsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending doctors found"));
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final imageUrl = doc['image']; // ✅ profile image

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  /// ✅ PROFILE IMAGE
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: imageUrl != null && imageUrl != ""
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null || imageUrl == ""
                        ? const Icon(Icons.person, color: Colors.blue)
                        : null,
                  ),

                  title: Text(doc['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Specialization: ${doc['specialization'] ?? ''}"),
                      Text("Contact: ${doc['contactNumber'] ?? ''}"),
                      Text("Experience: ${doc['doctorExperience'] ?? ''}"),
                      Text(
                          "Consultation Fee: ${doc['consultationFee'] ?? ''}"),
                      Text(
                          "Consultation Time: ${doc['consultationTime'] ?? ''}"),
                    ],
                  ),

                  /// ✅ APPROVE BUTTON
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('doctors')
                          .doc(doc.id)
                          .update({"isApproved": true});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Doctor approved successfully"),
                        ),
                      );
                    },
                    child: const Text("Approve"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
