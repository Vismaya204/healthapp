import 'package:flutter/material.dart';
import 'package:healthapp/view/userallscreen.dart';
import 'package:lottie/lottie.dart';

class Success extends StatelessWidget {
  const Success({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2),() {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Userallscreen(),));
    },);
    return Scaffold(body: Center(child: Lottie.asset("assets/Success.json"),),);
  }
}