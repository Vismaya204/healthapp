import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/appoinmentstatus.dart';
import 'package:intl/intl.dart';

class HospitalAppointments extends StatelessWidget {
  final String hospitalId;
  final String hospitalName;

  const HospitalAppointments({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 106, 186, 252),title: const Text("Hospital Appointments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('hospitalId', isEqualTo: hospitalId)
            .snapshots(), // ✅ CHANGED TO STREAM
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();

              final status = getAppointmentStatus(data, date); // ✅ ADDED
              final color = getStatusColor(status); // ✅ ADDED

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data['doctorName'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            status,
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(hospitalName),
                      Text(data['patientName'] ?? ''),
                      Text(DateFormat('dd MMM yyyy').format(date)),
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
