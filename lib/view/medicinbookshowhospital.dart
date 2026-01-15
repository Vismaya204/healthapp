import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Medicinbookshowhospital extends StatelessWidget {
  final String hospitalId;

  const Medicinbookshowhospital({
    super.key,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('hospitalId', isEqualTo: hospitalId)           
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;

              final String medicineId = data['medicineId'] ?? '';
              if (medicineId.isEmpty) return const SizedBox();

              final Timestamp? ts = data['createdAt'] as Timestamp?;
              final String dateText = ts != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(ts.toDate())
                  : 'Date not available';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('hospitals')
                    .doc(hospitalId)
                    .collection('medicines')
                    .doc(medicineId)
                    .get(),
                builder: (context, medSnap) {
                  if (!medSnap.hasData || !medSnap.data!.exists) {
                    return const SizedBox();
                  }

               final med = medSnap.data!.data() as Map<String, dynamic>;

/// 🔹 SAFE IMAGE EXTRACTION (CORRECT FIELD)
String imageUrl = '';
final img = med['imageUrl'];

if (img is String && img.isNotEmpty) {
  imageUrl = img;
} else if (img is List && img.isNotEmpty) {
  imageUrl = img.first.toString();
}




                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.medical_services, size: 60),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['name'] ?? 'Unknown Medicine',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("User: ${data['userName']}"),
                                Text("Quantity: ${data['quantity']}"),
                                Text("Price: ₹${data['price']}"),
                                Text(
                                  "Total: ₹${data['price'] * data['quantity']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("Payment: ${data['paymentMethod']}"),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
