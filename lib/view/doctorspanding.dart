import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Doctorspanding extends StatelessWidget {
  final String hospitalName; // pass the hospital name

  const Doctorspanding({super.key, required this.hospitalName});

  @override
  Widget build(BuildContext context) {
    final doctorsRef = FirebaseFirestore.instance
        .collection('doctors')
        .where('hospitalName', isEqualTo: hospitalName)
        .where('isApproved', isEqualTo: true); // only approved doctors

    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Doctors - $hospitalName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: doctorsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No approved doctors found.'));
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final name = doc['name'] ?? '';
              final specialization = doc['specialization'] ?? '';
              final contact = doc['contactNumber'] ?? '';
              final consultationFee = doc['consultationFee'] ?? '';
              final consultationTime = doc['consultationTime'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Specialization: $specialization'),
                      Text('Contact: $contact'),
                      Text('Fee: $consultationFee'),
                      Text('Time: $consultationTime'),
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
}
