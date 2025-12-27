import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovedHospitals extends StatelessWidget {
  const ApprovedHospitals({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("hospitals")
          .where("isApproved", isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No approved hospitals"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: doc["image"] != ""
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(doc["image"]),
                      )
                    : const CircleAvatar(child: Icon(Icons.local_hospital)),
                title: Text(doc["hospitalName"]),
                subtitle: Text(doc["location"]),
              ),
            );
          },
        );
      },
    );
  }
}
