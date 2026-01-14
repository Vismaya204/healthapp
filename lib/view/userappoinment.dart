import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/userallscreen.dart';
import 'package:intl/intl.dart';

class UserAppoinment extends StatelessWidget {
  const UserAppoinment({super.key});

  // 🔴 Cancel dialog
  void _showCancelDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content: const Text(
          "Are you sure you want to cancel this appointment?",
        ),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Cancel"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(docId)
                  .delete();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appointment cancelled"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Userallscreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Appointments"),
          backgroundColor: Colors.teal,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Firestore error:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No appointments found"));
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String docId = docs[index].id;

                final Timestamp dateTimestamp = data['date'];
                final DateTime appointmentDate = dateTimestamp.toDate();

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['doctorName'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          data['hospitalName'] ?? '',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 6),
                            Text(data['patientName'] ?? ''),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16),
                            const SizedBox(width: 6),
                            Text(data['phone'] ?? ''),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(appointmentDate),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// 🔴 Cancel Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.cancel, size: 18),
                            label: const Text("Cancel"),
                            onPressed: () {
                              _showCancelDialog(context, docId);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
