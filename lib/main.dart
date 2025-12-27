import 'package:flutter/material.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/controller/logincotro.dart';
import 'package:healthapp/controller/usersignupcontro.dart';
import 'package:healthapp/view/doctor-reg.dart';
import 'package:healthapp/view/hospital-reg.dart';
import 'package:healthapp/view/registerloginscreen.dart';
import 'package:healthapp/view/userregister.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthapp/firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HospitalController()),
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create:  (_) => AuthController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Registerloginscreen(),
    );
  }
}
