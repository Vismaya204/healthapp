import 'package:flutter/material.dart';
import 'package:healthapp/view/userbooking.dart';
import 'package:healthapp/view/userhome.dart';
import 'package:healthapp/view/userprofile.dart';

class Userallscreen extends StatefulWidget {
  const Userallscreen({super.key});

  @override
  State<Userallscreen> createState() => _UserallscreenState();
}

class _UserallscreenState extends State<Userallscreen> {
  int _currentIndex = 0;

  final List<Widget> _userpages = const [
    Userhome(),
    Userprofile(),
    Userbookingall(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userpages[_currentIndex],
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
        items: [BottomNavigationBarItem(icon:  Icon(  Icons.home), label: "Home"),
               BottomNavigationBarItem(icon:  Icon(  Icons.book_online), label: "Bookings"),
              BottomNavigationBarItem(icon:  Icon(  Icons.person), label: "Profile"),
          ],
      ),
    );
  }
}
