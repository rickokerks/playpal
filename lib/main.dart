import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart'; // Ensure the LoginPage is defined
import 'home.dart'; // Ensure the HomePage is defined

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & SignUp Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/login', // Start from login page
      routes: {
        '/login': (context) => const LoginPage(), // Navigate to LoginPage
        '/home': (context) =>
            const HomePage(accountId: 'user123'), // Navigate to HomePage
      },
    );
  }
}
