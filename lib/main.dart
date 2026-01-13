import 'package:flutter/material.dart';
import 'package:healthapp/view/usershowdoctor.dart';
import 'package:healthapp/view/usershowemergency.dart';
import 'package:healthapp/view/usershowmedicine.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:healthapp/firebase_options.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/controller/logincotro.dart';
import 'package:healthapp/controller/usersignupcontro.dart';
import 'package:healthapp/view/registerloginscreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HospitalController()),
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// ✅ ADD THIS (DO NOT REMOVE ANYTHING ELSE)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/medicine':
            final hospitalId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => MedicineScreen(hospitalId: hospitalId),
            );

       case '/doctors':
  final args = settings.arguments as Map<String, dynamic>;
  final hospitalName = args['hospitalName'] as String;
  final hospitalId = args['hospitalId'] as String;

  return MaterialPageRoute(
    builder: (_) => Usershowdoctor(
      hospitalName: hospitalName,
      hospitalId: hospitalId,
    ),
  );


          case '/emergency':
            final hospitalId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => Usershowemergency(hospitalId: hospitalId),
            );
        }
        return null;
      },

      /// 👇 keep your existing home
      home: const Registerloginscreen(),
    );
  }
}
