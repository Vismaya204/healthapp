import 'package:flutter/material.dart';
import 'package:healthapp/view/approvedhospital.dart';
import 'package:healthapp/view/hospitalpending.dart';

class Adminallscreen extends StatelessWidget {
  const Adminallscreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Card data
    final List<Map<String, dynamic>> cardData = [
      {
        'title': 'Hospital Pending',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
        'screen': PendingHospitals(), // Replace with your screen
      },
      {
        'title': 'Hospital Approved',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'screen': ApprovedHospitals(), // Replace with your screen
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: cardData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards in a row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // Square cards
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
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: data['color'],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      data['icon'],
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

