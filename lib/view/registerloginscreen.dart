import 'package:flutter/material.dart';
import 'package:healthapp/view/doctor-reg.dart';
import 'package:healthapp/view/hospital-reg.dart';
import 'package:healthapp/view/login.dart';
import 'package:healthapp/view/userregister.dart';
// import your other register screens
// import 'package:healthapp/view/doctor_register.dart';
// import 'package:healthapp/view/user_register.dart';

class Registerloginscreen extends StatelessWidget {
  const Registerloginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// REGISTER BUTTON
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showRegisterDialog(context);
                },
                child: const Text("Register"),
              ),
            ),

            const SizedBox(height: 20),

            /// LOGIN BUTTON
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Login()),
                  );
                },
                child: const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // REGISTER POPUP
  // ==========================
  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register As"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogButton(
                text: "Doctor",
                onTap: () {
                  Navigator.pop(context);
                   Navigator.push(context,
                     MaterialPageRoute(builder: (_) => DoctorReg()));
                },
              ),
              const SizedBox(height: 10),
              _dialogButton(
                text: "User",
                onTap: () {
                  Navigator.pop(context);
                 Navigator.push(context,
                     MaterialPageRoute(builder: (_) => Userregister()));
                },
              ),
              const SizedBox(height: 10),
              _dialogButton(
                text: "Hospital",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HospitalRegister()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
