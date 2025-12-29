import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingHospitals extends StatelessWidget {
  const PendingHospitals({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("hospitals")
          .where("isApproved", isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pending hospitals"));
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
                subtitle: Column(
                  children: [
                    Text("${doc["location"]}\n${doc["email"]}"),
                  
                  ],
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("hospitals")
                        .doc(doc.id)
                        .update({"isApproved": true});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Hospital Approved"),
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
    );
  }
}
