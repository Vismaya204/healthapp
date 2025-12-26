import 'package:flutter/material.dart';
import 'package:healthapp/controller/controller.dart';
import 'package:provider/provider.dart';

class DoctorReg extends StatefulWidget {
  const DoctorReg({super.key});

  @override
  State<DoctorReg> createState() => _DoctorRegState();
}

class _DoctorRegState extends State<DoctorReg> {
  TextEditingController doctorName = TextEditingController();
  TextEditingController specialization = TextEditingController();
  TextEditingController experience = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController availableDays = TextEditingController();
  TextEditingController consultationTime = TextEditingController();
  TextEditingController consultationFee = TextEditingController();
  TextEditingController hospitalName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Doctor Registration"),
            SizedBox(height: 20),
            TextFormField(
              controller: doctorName,
              decoration: InputDecoration(
                hintText: "Doctor Name",
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
            TextFormField(
              controller: specialization,
              decoration: InputDecoration(
                hintText: "Specialization",
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
            TextFormField(
              controller: experience,
              decoration: InputDecoration(
                hintText: "experience",
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
            TextFormField(
              controller: contactNumber,
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
            TextFormField(
              controller: email,
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
            TextFormField(
              controller: password,
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
            SizedBox(height: 10),
            TextFormField(
              controller: availableDays,
              decoration: InputDecoration(
                hintText: "Available Days",
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
            TextFormField(
              controller: consultationTime,
              decoration: InputDecoration(
                hintText: "Consultation Time",
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
            TextFormField(
              controller: consultationFee,
              decoration: InputDecoration(
                hintText: "Consultation Fee",
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
            TextFormField(
              controller: hospitalName,
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
            SizedBox(height: 20),
            Consumer<HospitalController>(
  builder: (context, controller, _) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,foregroundColor: Colors.white),
      onPressed: controller.isLoading ? null : () {
        context.read<HospitalController>().registerDoctor(
          name: doctorName.text,
          specialization: specialization.text,
          doctorExperience: experience.text,
          contactNumber: contactNumber.text,
          email: email.text,
          password: password.text,
          consultationTime: consultationTime.text,
          consultationFee: consultationFee.text,
          hospitalName: hospitalName.text,
          availableDaysText: availableDays.text,
          context: context,
        );
      },
      child: controller.isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Sign up"),
    );
  },
),

          ],
        ),
      ),
    );
  }
}
