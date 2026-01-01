import 'package:flutter/material.dart';
import 'package:healthapp/view/doctor-reg.dart';
import 'package:healthapp/view/hospital-reg.dart';
import 'package:healthapp/view/login.dart';
import 'package:healthapp/view/userregister.dart';

class Registerloginscreen extends StatelessWidget {
  const Registerloginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🏥 APP ICON
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 55,
              ),
            ),

            const SizedBox(height: 20),

            /// APP TITLE
            Text(
              "Health Care App",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),

            const SizedBox(height: 6),

            /// TAGLINE
            Text(
              "Your trusted digital health partner",
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey.shade700,
              ),
            ),

            const SizedBox(height: 8),

            /// DESCRIPTION
            Text(
              "Connecting Doctors, Hospitals & Patients in one platform",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 40),

            /// HELPER TEXT
            Text(
              "Get started by creating an account",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 15),

            /// REGISTER CARD
            _mainCard(
              icon: Icons.app_registration,
              title: "Register",
              subtitle: "Create a new account as Doctor, User or Hospital",
              onTap: () => _showRegisterDialog(context),
            ),

            const SizedBox(height: 20),

            /// LOGIN CARD
            _mainCard(
              icon: Icons.login,
              title: "Login",
              subtitle: "Login to manage appointments & services",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Login()),
                );
              },
            ),

            const SizedBox(height: 30),

            /// FOOTER
            Text(
              "Secure • Reliable • Easy to use",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
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
      builder: (_) {
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
                icon: Icons.medical_services,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorReg()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _dialogButton(
                text: "User",
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Userregister()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _dialogButton(
                text: "Hospital",
                icon: Icons.local_hospital,
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

  // ==========================
  // MAIN CARD
  // ==========================
  Widget _mainCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: Icon(icon, color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 200,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // DIALOG BUTTON
  // ==========================
  Widget _dialogButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: onTap,
      ),
    );
  }
}
