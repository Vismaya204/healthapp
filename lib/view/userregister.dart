import 'package:flutter/material.dart';
import 'package:healthapp/controller/usersignupcontro.dart';
import 'package:healthapp/model/model.dart';
import 'package:provider/provider.dart';

class Userregister extends StatefulWidget {
  const Userregister({super.key});

  @override
  State<Userregister> createState() => _UserregisterState();
}

class _UserregisterState extends State<Userregister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController location = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final signupController = context.watch<SignupController>();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// 🏥 HEADER
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.person_add_alt_1,
                  size: 45,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Register to access healthcare services",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 30),

              /// USERNAME
              _inputField(
                controller: username,
                hint: "Username",
                icon: Icons.person,
                validator: (v) =>
                    v!.isEmpty ? "Username required" : null,
              ),

              const SizedBox(height: 15),

              /// LOCATION
              _inputField(
                controller: location,
                hint: "Location",
                icon: Icons.location_on,
                validator: (v) =>
                    v!.isEmpty ? "Location required" : null,
              ),

              const SizedBox(height: 15),

              /// EMAIL
              _inputField(
                controller: email,
                hint: "Email Address",
                icon: Icons.email,
                keyboard: TextInputType.emailAddress,
                validator: (v) =>
                    v!.isEmpty ? "Email required" : null,
              ),

              const SizedBox(height: 15),

              /// PASSWORD
              TextFormField(
                controller: password,
                obscureText: _obscurePassword,
                validator: (v) =>
                    v!.length < 6 ? "Minimum 6 characters" : null,
                decoration: _passwordDecoration(),
              ),

              const SizedBox(height: 15),

              /// PHONE
              _inputField(
                controller: phoneNumber,
                hint: "Phone Number",
                icon: Icons.phone,
                keyboard: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? "Phone number required" : null,
              ),

              const SizedBox(height: 30),

              /// SIGNUP BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: signupController.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            final user = AppUserModel(
                              uid: "",
                              username: username.text.trim(),
                              email: email.text.trim(),
                              phoneNumber: phoneNumber.text.trim(),
                              location: location.text.trim(),
                              createdAt: DateTime.now(),
                            );

                            signupController.signupUser(
                              user: user,
                              password: password.text.trim(),
                              context: context,
                            );
                          }
                        },
                  child: signupController.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Safe & Secure Hospital Registration",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =============================
  /// COMMON INPUT FIELD UI
  /// =============================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  /// =============================
  /// PASSWORD FIELD UI
  /// =============================
  InputDecoration _passwordDecoration() {
    return InputDecoration(
      hintText: "Password",
      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: Colors.blue,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}
