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

  final List<Widget> _pages = const [
    HospitalHome(),
    Doctorspanding(),
    Emergencyhospitalbookingall(),
    Userbookingallhospitalbased(),
    Hospitalprofile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

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
