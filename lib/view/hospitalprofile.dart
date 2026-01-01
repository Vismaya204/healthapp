import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/model/model.dart';

class HospitalProfile extends StatelessWidget {
  const HospitalProfile({super.key});

  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Profile"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<HospitalModel?>(
        stream: context.read<HospitalController>().getCurrentHospitalStream(),
        builder: (context, snapshot) {
          // Loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error handling
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Null check
          final hospital = snapshot.data;
          if (hospital == null) {
            return const Center(
                child: Text(
              "Hospital data not found",
              style: TextStyle(fontSize: 18),
            ));
          }

          // ✅ Show profile
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: (hospital.image.isNotEmpty)
                      ? NetworkImage(hospital.image)
                      : null,
                  child: (hospital.image.isEmpty)
                      ? const Icon(Icons.local_hospital,
                          size: 60, color: Colors.blue)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  hospital.hospitalName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  hospital.location,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(hospital.email),
                  ),
                ),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(hospital.contactNumber),
                  ),
                ),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(hospital.description),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
