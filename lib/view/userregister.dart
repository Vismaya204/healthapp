import 'package:flutter/material.dart';
import 'package:healthapp/controller/usersignupcontro.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController location = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final signupController = Provider.of<SignupController>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Signup",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Username
            TextField(
              controller: username,
              decoration: _inputDecoration("Username"),
            ),
            const SizedBox(height: 10),

            // Location ✅
            TextField(
              controller: location,
              decoration: _inputDecoration("Location"),
            ),
            const SizedBox(height: 10),

            // Email
            TextField(
              controller: email,
              decoration: _inputDecoration("Email"),
            ),
            const SizedBox(height: 10),

            // Password ✅
            TextField(
              controller: password,
              obscureText: _obscurePassword,
              decoration: _inputDecoration("Password").copyWith(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Phone Number ✅
            TextField(
              controller: phoneNumber,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Phone Number"),
            ),
            const SizedBox(height: 20),

            // Signup Button
            signupController.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      signupController.signupUser(
                        username: username.text.trim(),
                        email: email.text.trim(),
                        password: password.text.trim(),
                        phoneNumber: phoneNumber.text.trim(),
                        location: location.text.trim(),
                        context: context,
                      );
                    },
                    child: const Text("Sign up"),
                  ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
