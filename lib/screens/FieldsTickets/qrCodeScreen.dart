// import 'package:flutter/material.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Barcode Scanner',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: BarcodeScannerScreen(),
//     );
//   }
// }

// class BarcodeScannerScreen extends StatefulWidget {
//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   String scannedCode = '';

//   @override
//   void initState() {
//     super.initState();
//     startScanning();
//   }

//   Future<void> startScanning() async {
//     print('Scan started');
//     try {
//       var scanResult = await BarcodeScanner.scan();

//       if (scanResult.rawContent.isNotEmpty) {
//         setState(() {
//           scannedCode = scanResult.rawContent; // Stocker le code scanné
//         });
//         print('Scanned Code: $scannedCode');

//         // Afficher le code scanné pendant 3 secondes avant de revenir à la page précédente
//         await Future.delayed(Duration(seconds: 3));
//         Navigator.pop(context, scannedCode); // Retourner avec le code scanné
//       } else {
//         print('Failed to scan, no result');
//       }
//     } catch (e) {
//       print('Failed to scan, error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     // Libérer les ressources si nécessaire
//     super.dispose(); // Appeler la méthode de la classe parente
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Barcode Scanner'),
//       ),
//       body: Center(
//         child: Text(
//           scannedCode.isEmpty ? 'Scanning...' : 'Scanned Code: $scannedCode',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
