import 'package:flutter/material.dart';
import 'dart:async';
import 'package:todo/screens/auth/login_screen.dart';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    print('ImageScreen est en cours');

    // Option : Redirection après 5 secondes
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel(); // Annule le timer ici si nécessaire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/Hi_TSS.png', // Remplace par le nom de ton image
          fit: BoxFit.cover, // Ajuste le style de l'image
        ),
      ),
    );
  }
}
