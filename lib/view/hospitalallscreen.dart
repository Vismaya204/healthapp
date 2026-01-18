import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/hospitalemergencyhandle.dart';
import 'package:healthapp/view/hospital-home.dart';
import 'package:healthapp/view/hospitalprofile.dart';
import 'package:healthapp/view/hospitalbasedshowappoinments.dart';

class Hospitalallscreen extends StatefulWidget {
  const Hospitalallscreen({super.key});

  @override
  State<Hospitalallscreen> createState() => _HospitalallscreenState();
}

class _HospitalallscreenState extends State<Hospitalallscreen> {
  int _currentIndex = 0;
  String hospitalId = "";
  String hospitalName = ""; // 🔹 Hospital name for bookings tab
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalData();
  }

  Future<void> fetchHospitalData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      hospitalId = user.uid;

      // Fetch hospital name from Firestore using hospitalId
      final doc = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalId)
          .get();

      if (doc.exists) {
        hospitalName = doc.data()?['name'] ?? "";
      }
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

    final pages = [
      const HospitalHome(),
      HospitalAmbulanceScreen(hospitalId: hospitalId),
      HospitalAppointments(hospitalName: hospitalName,hospitalId: hospitalId,),// ✅ Pass hospitalName
      const HospitalProfile(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital), label: "Emergency"),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_online), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
