import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Usermedicinebook extends StatelessWidget {
  const Usermedicinebook({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medicine Orders"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userName', isEqualTo: user.displayName) // ✅ MATCH IMAGE
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No medicine orders found"),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final Timestamp time = data['createdAt'];
              final DateTime date = time.toDate();

            return Card(
  elevation: 4,
  margin: const EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('hospitals')
          .doc(data['hospitalId'])
          .collection('medicines')
          .doc(data['medicineId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: const [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(
                  child: LinearProgressIndicator(
                minHeight: 16,
              )),
            ],
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.medical_services),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User: ${data['userName']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Unknown Medicine",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final medData = snapshot.data!.data() as Map<String, dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🖼 Medicine Image
                CircleAvatar(
                  radius: 30,
                  backgroundImage: medData['imageUrl'] != null &&
                          medData['imageUrl'].toString().isNotEmpty
                      ? NetworkImage(medData['imageUrl'])
                      : null,
                  child: medData['imageUrl'] == null
                      ? const Icon(Icons.medical_services)
                      : null,
                ),

                const SizedBox(width: 12),

                /// 📄 User & Medicine Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User: ${data['userName']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medData['name'] ?? "Unknown Medicine",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text("Quantity: ${data['quantity']}"),
                      Text("Price: ₹${data['price']}"),
                      Text(
                        "Total: ₹${data['totalPrice']}",
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w200),
                      ),
                      const SizedBox(height: 6),
                      Text("Payment: ${data['paymentMethod']}"),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format((data['createdAt'] as Timestamp).toDate()),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Cancel Button Row
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  // Optional: show a confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Cancel Order"),
                      content:
                          const Text("Are you sure you want to cancel this order?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  try {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orders[index].id)
                        .delete(); // Deletes order
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order cancelled")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                icon: const Icon(Icons.cancel, color: Colors.red),
                label: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        );
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
Widget _medicineImageAndName(String hospitalId, String medicineId) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('medicines')
        .doc(medicineId)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const CircleAvatar(
          radius: 30,
          child: Icon(Icons.medical_services),
        );
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;

      return Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: data['imageUrl'] != null &&
                    data['imageUrl'].toString().isNotEmpty
                ? NetworkImage(data['imageUrl'])
                : null,
            child: data['imageUrl'] == null
                ? const Icon(Icons.medical_services)
                : null,
          ),
          
          
        ],
      );
    },
  );
}
