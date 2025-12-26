import 'package:flutter/material.dart';

class HospitalRegister extends StatefulWidget {
  const HospitalRegister({super.key});

  @override
  State<HospitalRegister> createState() => _HospitalRegisterState();
}

class _HospitalRegisterState extends State<HospitalRegister> {
  TextEditingController hospitalName = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Hospital Registration"),
          SizedBox(height: 20),
          Container(
            height: 100,
            width: 100,
            color: Colors.grey[300],
            child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[700]),//image upload
          ),
          TextFormField(controller: hospitalName,
            decoration: InputDecoration(
              hintText: "Hospital Name",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            cursorColor: Colors.blue,
          ),
          SizedBox(height: 10),
          TextFormField(controller: location,
            decoration: InputDecoration(
              hintText: "Location",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            cursorColor: Colors.blue,
          ),
          SizedBox(height: 10),
          TextFormField(controller: contactNumber,
            decoration: InputDecoration(
              hintText: "Contact Number",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            cursorColor: Colors.blue,
          ),
          SizedBox(height: 10),
          TextFormField(controller: email,
            decoration: InputDecoration(
              hintText: "Email",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            cursorColor: Colors.blue,
          ),
          SizedBox(height: 10),
          TextFormField(controller: password,
            decoration: InputDecoration(
              hintText: "Password",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            cursorColor: Colors.blue,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: Text("Sign Up"),
          ),
        ],
      ),
    );
  }
}
