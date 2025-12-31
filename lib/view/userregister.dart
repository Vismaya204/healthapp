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
  // ✅ FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        child: Form( // ✅ FORM ADDED
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "User Signup",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              /// USERNAME
              TextFormField(
                controller: username,
                decoration: _inputDecoration("Username"),
                validator: (v) =>
                    v!.isEmpty ? "Username required" : null,
              ),
              const SizedBox(height: 10),

              /// LOCATION
              TextFormField(
                controller: location,
                decoration: _inputDecoration("Location"),
                validator: (v) =>
                    v!.isEmpty ? "Location required" : null,
              ),
              const SizedBox(height: 10),

              /// EMAIL
              TextFormField(
                controller: email,
                decoration: _inputDecoration("Email"),
                validator: (v) =>
                    v!.isEmpty ? "Email required" : null,
              ),
              const SizedBox(height: 10),

              /// PASSWORD
              TextFormField(
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
                validator: (v) =>
                    v!.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 10),

              /// PHONE
              TextFormField(
                controller: phoneNumber,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Phone Number"),
                validator: (v) =>
                    v!.isEmpty ? "Phone number required" : null,
              ),
              const SizedBox(height: 20),

              /// SIGNUP BUTTON
              signupController.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: signupController.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final user = AppUserModel(
                                  uid: "", // replaced in controller
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
                      child: const Text("Sign up"),
                    ),
            ],
          ),
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
