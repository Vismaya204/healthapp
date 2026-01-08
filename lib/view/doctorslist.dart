import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorListScreen extends StatelessWidget {
  final String category;
  final String hospitalId;

  const DoctorListScreen({
    super.key,
    required this.category,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context) {
    final stream = category == "All"
        ? FirebaseFirestore.instance
            .collection('doctors')
            .where('approved', isEqualTo: true)
            .where('hospitalId', isEqualTo: hospitalId)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('doctors')
            .where('approved', isEqualTo: true)
            .where('hospitalId', isEqualTo: hospitalId)
            .where('specialization', isEqualTo: category)
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("$category Doctors"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No doctors found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return _doctorCard(doctor);
            },
          );
        },
      ),
    );
  }

  Widget _doctorCard(QueryDocumentSnapshot doctor) {
    final imageUrl = doctor['image'] ?? '';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 32, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialization'] ?? '',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text("Experience: ${doctor['experience'] ?? ''} yrs"),
                  const SizedBox(height: 4),
                  Text(
                    "Consultation Fee: ₹${doctor['fee'] ?? ''}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
