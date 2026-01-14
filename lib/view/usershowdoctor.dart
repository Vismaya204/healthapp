import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/userallscreen.dart';

class Usershowdoctor extends StatefulWidget {
  final String hospitalName;
  final String hospitalId;

  const Usershowdoctor({
    super.key,
    required this.hospitalName,
    required this.hospitalId,
  });

  @override
  State<Usershowdoctor> createState() => _UsershowdoctorState();
}

class _UsershowdoctorState extends State<Usershowdoctor> {
  TextEditingController searchController = TextEditingController();
String searchText = '';

  
  String selectedCategory = "All";

  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.medical_services, "color": Colors.teal},
    {"name": "Cardiologist", "icon": Icons.favorite, "color": Colors.red},
    {"name": "Dentist", "icon": Icons.medical_services, "color": Colors.blue},
    {"name": "Neurologist", "icon": Icons.psychology, "color": Colors.purple},
    {"name": "Dermatologist", "icon": Icons.face, "color": Colors.orange},
    {"name": "Pediatrician", "icon": Icons.child_care, "color": Colors.green},
    {"name": "Gynaecology", "icon": Icons.female, "color": Colors.pink},
  ];

  Query<Map<String, dynamic>> getDoctorQuery() {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('doctors')
      .where('isApproved', isEqualTo: true)
      .where('hospitalName', isEqualTo: widget.hospitalName); // use name

  if (selectedCategory != "All") {
    query = query.where('specialization', isEqualTo: selectedCategory);
  }

  return query;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Doctors in ${widget.hospitalName}"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          /// 🔎 SEARCH (UI Only)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
  controller: searchController,
  onChanged: (value) {
    setState(() {
      searchText = value.toLowerCase();
    });
  },
  decoration: const InputDecoration(
    hintText: "Search doctors...",
    border: InputBorder.none,
    icon: Icon(Icons.search),
  ),
),

            ),
          ),

          /// 🌈 Categories
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat['name'];
                    });
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: cat['color'],
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'], color: Colors.white, size: 30),
                        const SizedBox(height: 6),
                        Text(
                          cat['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// 👨‍⚕️ Doctor List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getDoctorQuery().snapshots(),
              builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }

  if (snapshot.hasError) {
    return const Center(
      child: Text("Something went wrong"),
    );
  }

  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(
      child: Text(
        "No doctors found",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  final doctors = snapshot.data!.docs;

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: doctors.length,
    itemBuilder: (context, index) {
      final doc = doctors[index];
      return _doctorCard(doc.data(), doc.id);
    },
  );
},

            ),
          ),
        ],
      ),
    );
  }

 Widget _doctorCard(Map<String, dynamic> doctor, String docId) {
  final imageUrl = doctor['image'] ?? '';
  final consultationTime = doctor['consultationTime'] ?? 'Not set';
  final contactNumber = doctor['contactNumber'] ?? 'N/A';
  final availableDays = doctor['availableDays'] != null
      ? (doctor['availableDays'] as List<dynamic>).join(", ")
      : 'Not available';

  return Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue.shade100,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 32, color: Colors.blue)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialization'] ?? '',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Experience: ${doctor['doctorExperience'] ?? 0} yrs",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Contact: $contactNumber",
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Fee: ₹${doctor['consultationFee'] ?? 0}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Time: $consultationTime",
                      style: TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Days: $availableDays",
                      style: TextStyle(color: Colors.pink),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to doctor details page if needed
                },
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 🩺 Appointment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
             onPressed: () {
  _showAppointmentBottomSheet({
    ...doctor,
    'hospitalId': widget.hospitalId,      // ✅ PASS REAL ID
    'hospitalName': widget.hospitalName,  // ✅ PASS NAME
  }, docId);
},

              icon: const Icon(Icons.calendar_today),
              label: const Text("Book Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Function to show bottom sheet
void _showAppointmentBottomSheet(
    Map<String, dynamic> doctor, String docId) {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  String gender = 'Male';
  DateTime? selectedDate;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Book Appointment with ${doctor['name']}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ['Male', 'Female', 'Other']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          gender = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(selectedDate == null
                        ? "Select Date"
                        : "Date: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                    onPressed: () async {
  if (nameController.text.isEmpty ||
      ageController.text.isEmpty ||
      phoneController.text.isEmpty ||
      selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser; // ✅ GET LOGIN USER

 await FirebaseFirestore.instance.collection('appointments').add({
  'userId': user!.uid,
  'email': user.email,
  'doctorId': docId,
  'doctorName': doctor['name'],
  'hospitalId': widget.hospitalId,   // ✅ FIX HERE
  'hospitalName': widget.hospitalName,
  'patientName': nameController.text,
  'age': ageController.text,
  'gender': gender,
  'phone': phoneController.text,
  'date': selectedDate,
  'createdAt': Timestamp.now(),
});

  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AppointmentConfirmedScreen(
        doctorName: doctor['name'],
        hospitalName: doctor['hospitalName'],
        appointmentDate: selectedDate!,
      ),
    ),
  );
},

                      child: const Text("Confirm Appointment"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}


}
class AppointmentConfirmedScreen extends StatelessWidget {
  final String doctorName;
  final String hospitalName;
  final DateTime appointmentDate;

  const AppointmentConfirmedScreen({
    super.key,
    required this.doctorName,
    required this.hospitalName,
    required this.appointmentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Appointment Confirmed"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              Text(
                "Your appointment is confirmed!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Doctor: $doctorName",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "Hospital: $hospitalName",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: ${appointmentDate.day}-${appointmentDate.month}-${appointmentDate.year}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Userallscreen(),));
                },
                child: const Text("Back to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

