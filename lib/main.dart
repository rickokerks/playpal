import 'package:flutter/material.dart';
import 'login.dart'; 
//ra ra ra ahh ahh
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & SignUp Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: LoginPage(
          userData: {}), 
    );
  }
}
