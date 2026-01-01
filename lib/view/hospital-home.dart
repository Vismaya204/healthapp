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

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.local_hospital,
                        color: Colors.blue, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          hospitalName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= DASHBOARD =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    _dashboardCard(
                      title: "Doctor Requests",
                      subtitle: "Pending approvals",
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Doctorspanding(hospitalName: hospitalName),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      title: "Emergency",
                      subtitle: "Immediate cases",
                      icon: Icons.emergency,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const Emergencyhospitalbookingall(),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      title: "Hospital Info",
                      subtitle: "Profile details",
                      icon: Icons.info_outline,
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
                      title: "Doctors",
                      subtitle: "All specialists",
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
                      title: "Bookings",
                      subtitle: "Patient appointments",
                      icon: Icons.book_online,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const Userbookingallhospitalbased(),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      title: "Today Doctors",
                      subtitle: "Available now",
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
                      title: "Medicine",
                      subtitle: "Pharmacy services",
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
            ),
          ],
        ),
      ),
    );
  }

  /// ================= COLORED CARD =================
  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
