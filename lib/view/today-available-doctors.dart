import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Todayavailabledoc extends StatelessWidget {
  const Todayavailabledoc({super.key});

  @override
  Widget build(BuildContext context) {
    String today =
        DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    final doctorsRef = FirebaseFirestore.instance
        .collection('doctors')
        .where('availableDays', arrayContains: today);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Today Available Doctors'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: doctorsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No doctors available today',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final data =
                  doctors[index].data() as Map<String, dynamic>;

              final imageUrl = data['profileImage'];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),

                  /// ✅ PROFILE IMAGE FIX
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.blue,
                          )
                        : null,
                  ),

                  title: Text(
                    data['name'] ?? 'Doctor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data['specialization'] ?? 'Specialist',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  onTap: () {
                    // Navigate to doctor details / booking
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
