import 'package:flutter/material.dart';
import 'package:healthapp/controller/logincotro.dart';
import 'package:healthapp/view/forgotpass.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            /// 🏥 LOGO
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 55,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Sign in to continue your healthcare journey",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 40),

            /// 📧 EMAIL
            _beautifulField(
              controller: email,
              hint: "Email Address",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 18),

            /// 🔒 PASSWORD
            TextFormField(
              controller: password,
              obscureText: _obscurePassword,
              decoration: _inputDecoration(
                hint: "Password",
                icon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),GestureDetector(onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Forgotpass(),));
            },child: Align(alignment: Alignment.bottomRight,child: Text("Forgotpassword"))),

            const SizedBox(height: 30),

            /// 🔐 LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                onPressed: authController.isLoading
                    ? null
                    : () {
                        authController.login(
                          email: email.text.trim(),
                          password: password.text.trim(),
                          context: context,
                        );
                      },
                child: authController.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Doctors • Hospitals • Patients",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================
  /// BEAUTIFUL INPUT FIELD
  /// ==========================
  Widget _beautifulField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(
        hint: hint,
        icon: icon,
      ),
    );
  }

  /// ==========================
  /// COMMON DECORATION
  /// ==========================
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }
}
