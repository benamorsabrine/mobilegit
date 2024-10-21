import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FieldTicket(),
    );
  }
}

class FieldTicket extends StatelessWidget {
  const FieldTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page daccueil'),
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur Field Ticket!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}