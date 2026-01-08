import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// ===================================================
/// DOCTOR CATEGORIES SCREEN
/// ===================================================
class DoctorCategoriesScreen extends StatelessWidget {
  final String hospitalName;

  const DoctorCategoriesScreen({
    super.key,
    required this.hospitalName,
  });

  final List<Map<String, dynamic>> categories = const [
    {"name": "Cardiologist", "icon": Icons.favorite, "color": Colors.red},
    {"name": "Dentist", "icon": Icons.medical_services, "color": Colors.blue},
    {"name": "Neurologist", "icon": Icons.psychology, "color": Colors.purple},
    {"name": "Dermatologist", "icon": Icons.face, "color": Colors.orange},
    {"name": "Pediatrician", "icon": Icons.child_care, "color": Colors.green},
    {"name": "Gynaecology", "icon": Icons.female, "color": Colors.pink},
    {"name": "All", "icon": Icons.medical_services, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Categories"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue.shade50,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorListScreen(
                    category: category['name'],
                    hospitalName: hospitalName,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    size: 40,
                    color: category['color'],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ===================================================
/// DOCTOR LIST SCREEN
/// ===================================================
class DoctorListScreen extends StatelessWidget {
  final String category;
  final String hospitalName;

  const DoctorListScreen({
    super.key,
    required this.category,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('doctors')
        .where('isApproved', isEqualTo: true)
        .where('hospitalName', isEqualTo: hospitalName);

    if (category != "All") {
      query = query.where('specialization', isEqualTo: category);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$category Doctors"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue.shade50,
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _doctorCard(snapshot.data!.docs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _doctorCard(QueryDocumentSnapshot doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(doctor['image']),
        ),
        title: Text(
          doctor['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor['specialization']),
              Text("Experience: ${doctor['doctorExperience']}"),
              Text(
                "Fee: ₹${doctor['consultationFee']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Doctor detail / booking screen
        },
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No doctors found",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
