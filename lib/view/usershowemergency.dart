import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/model/model.dart';

class Usershowemergency extends StatelessWidget {
  final String hospitalId;

  const Usershowemergency({
    super.key,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context) {
    final ambulanceRef = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('ambulances')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Service'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ambulanceRef.snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No ambulance service available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final ambulances = snapshot.data!.docs
              .map((doc) => AmbulanceModel.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ambulances.length,
            itemBuilder: (context, index) {
              final ambulance = ambulances[index];
print(ambulance.contactNumber);
print(ambulance.drivername);

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.local_hospital, color: Colors.white),
                  ),
                  title:  Text('${ambulance.drivername}',
                   
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    
                    child: Text(
                      '📞 ${ambulance.contactNumber}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      // integrate call later
                    },
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
