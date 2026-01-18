import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/approvedhospital.dart';
import 'package:healthapp/view/hospitalpending.dart';
import 'package:intl/intl.dart';


class Adminallscreen extends StatelessWidget {
  const Adminallscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cardData = [
      {
        'title': 'Hospital Pending',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
        'screen': const PendingHospitals(),
      },
      {
        'title': 'Hospital Approved',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'screen': const ApprovedHospitals(),
      },
      {
        'title': 'Medicine Bookings',
        'icon': Icons.medical_services,
        'color': Colors.purple,
        'screen': const AdminMedicineOrders(), // ✅ FIX
      },
      {
  'title': 'User Appointments',
  'icon': Icons.calendar_today,
  'color': Colors.blue,
  'screen': const AdminAllAppointments(), // ✅ FIXED
},

    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final data = cardData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => data['screen']),
              );
            },
            child: Card(
              color: data['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(data['icon'], size: 50, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    data['title'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}




class AdminMedicineOrders extends StatelessWidget {
  const AdminMedicineOrders({super.key});

  /// 🔹 Fetch hospital name using hospitalId
  Future<String> getHospitalName(String hospitalId) async {
    final doc = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['hospitalName'] ?? 'Unknown Hospital';
    }
    return 'Unknown Hospital';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Medicine Orders"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
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
              final data =
                  orders[index].data() as Map<String, dynamic>;

              final String hospitalId = data['hospitalId'] ?? '';
              final String medicineId = data['medicineId'] ?? '';

              if (hospitalId.isEmpty || medicineId.isEmpty) {
                return const SizedBox();
              }

              final Timestamp? ts = data['createdAt'];
              final dateText = ts != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(ts.toDate())
                  : 'N/A';

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

                  final med =
                      medSnap.data!.data() as Map<String, dynamic>;

                  /// ✅ SAFE IMAGE
                  String imageUrl = '';
                  final img = med['imageUrl'];

                  if (img is String && img.isNotEmpty) {
                    imageUrl = img;
                  } else if (img is List && img.isNotEmpty) {
                    imageUrl = img.first.toString();
                  }

                  return FutureBuilder<String>(
                    future: getHospitalName(hospitalId),
                    builder: (context, hospitalSnap) {
                      final hospitalName =
                          hospitalSnap.data ?? 'Loading...';

                      return Card(
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
                                    : const Icon(
                                        Icons.medical_services,
                                        size: 60,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med['name'] ?? 'Unknown Medicine',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Hospital: $hospitalName"),
                                    Text(
                                        "User: ${data['userName'] ?? 'N/A'}"),
                                    Text(
                                        "Quantity: ${data['quantity'] ?? 0}"),
                                    Text(
                                        "Price: ₹${data['price'] ?? 0}"),
                                    Text(
                                      "Total: ₹${(data['price'] ?? 0) * (data['quantity'] ?? 0)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "Payment: ${data['paymentMethod'] ?? 'N/A'}"),
                                    Text(
                                      dateText,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey),
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
          );
        },
      ),
    );
  }
}


class AdminAllAppointments extends StatelessWidget {
  const AdminAllAppointments({super.key});

  /// 🔹 Fetch hospital name
  Future<String> getHospitalName(String hospitalId) async {
    final doc = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .get();

    if (doc.exists) {
      return doc['hospitalName'] ?? 'Unknown Hospital';
    }
    return 'Unknown Hospital';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Appointments"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments') // ✅ NO user filter
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments found"));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data =
                  appointments[index].data() as Map<String, dynamic>;

              final String hospitalId = data['hospitalId'] ?? '';

              final Timestamp? ts = data['appointmentDate'];
              final dateText = ts != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(ts.toDate())
                  : 'N/A';

              return FutureBuilder<String>(
                future: getHospitalName(hospitalId),
                builder: (context, hospitalSnap) {
                  final hospitalName =
                      hospitalSnap.data ?? 'Loading...';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🏥 Hospital
                          Text(
                            hospitalName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 6),

                          /// 👤 User
                          Text("User: ${data['patientName'] ?? 'N/A'}"),

                          /// 👨‍⚕️ Doctor
                          Text(
                              "Doctor: ${data['doctorName'] ?? 'N/A'}"),

                         
                        

                          /// 🔖 Status Badge
                          Align(
                            alignment: Alignment.centerRight,
                            child: Chip(
                              label: Text(
                                data['status'] ?? 'pending',
                                style:
                                    const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  data['status'] == 'approved'
                                      ? Colors.green
                                      : data['status'] == 'cancelled'
                                          ? Colors.red
                                          : Colors.orange,
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
