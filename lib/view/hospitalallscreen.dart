import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/doctorspanding.dart';
import 'package:healthapp/view/emergencybookingall.dart';
import 'package:healthapp/view/hospital-home.dart';
import 'package:healthapp/view/hospitalprofile.dart';
import 'package:healthapp/view/userbookingall-hospitalbased.dart';

class Hospitalallscreen extends StatefulWidget {
  const Hospitalallscreen({super.key});

  @override
  State<Hospitalallscreen> createState() => _HospitalallscreenState();
}

class _HospitalallscreenState extends State<Hospitalallscreen> {
  int _currentIndex = 0;
  String hospitalName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalName();
  }

  // ==========================
  // FETCH LOGGED-IN HOSPITAL NAME
  // ==========================
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pages = [
      const HospitalHome(),
      Doctorspanding(hospitalName: hospitalName), // ✅ FIXED
      const Emergencyhospitalbookingall(),
      const Userbookingallhospitalbased(),
      const Hospitalprofile(),
    ];

    return Scaffold(
      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Doctor Pending",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: "Emergency",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
