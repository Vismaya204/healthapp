import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/doctorspanding.dart';
import 'package:healthapp/view/emergencybookingall.dart';
import 'package:healthapp/view/medicsn.dart';
import 'package:healthapp/view/today-available-doctors.dart';
import 'package:healthapp/view/userbookingall-hospitalbased.dart';
import 'package:healthapp/view/view-doctorallcategories.dart';
import 'package:healthapp/view/view-hospitaldetail.dart';

class HospitalHome extends StatefulWidget {
  const HospitalHome({super.key});

  @override
  State<HospitalHome> createState() => _HospitalHomeState();
}

class _HospitalHomeState extends State<HospitalHome> {
  String hospitalName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalName();
  }

  Future<void> fetchHospitalName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("hospitals")
        .doc(uid)
        .get();

    if (doc.exists) {
      hospitalName = doc["hospitalName"];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ WAIT UNTIL hospitalName LOADS
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _dashboardCard(
              context,
              title: "Doctor Pending",
              icon: Icons.pending_actions,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Doctorspanding(
                      hospitalName: hospitalName, // ✅ FIXED
                    ),
                  ),
                );
              },
            ),
            _dashboardCard(
              context,
              title: "Emergency",
              icon: Icons.local_hospital,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Emergencyhospitalbookingall(),
                  ),
                );
              },
            ),
            _dashboardCard(
              context,
              title: "Hospital Details",
              icon: Icons.info,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HospitalDetails(),
                  ),
                );
              },
            ),
            _dashboardCard(
              context,
              title: "All Doctors",
              icon: Icons.medical_services,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Doctorallcategories(),
                  ),
                );
              },
            ),
            _dashboardCard(
              context,
              title: "User Bookings",
              icon: Icons.book_online,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Userbookingallhospitalbased(),
                  ),
                );
              },
            ),
            _dashboardCard(
              context,
              title: "Today's Doctors",
              icon: Icons.today,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Todayavailabledoc(),
                  ),
                );
              },
            ),
            _dashboardCard(
              context,
              title: "Medicine",
              icon: Icons.medication,
              color: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Medisin(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
