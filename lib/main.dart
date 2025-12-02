import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const PetVetApp());
}

class PetVetApp extends StatelessWidget {
  const PetVetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetVet',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginPage(),
    );
  }
}
