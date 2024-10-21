import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();

  String adresse = '';
  String port = '';
  String id = '';
  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      this.id = prefs.getString('id') ?? ''; // Load the id value
      this.adresse = prefs.getString('adresse') ?? ''; // Load adresse
      this.port = prefs.getString('port') ?? ''; // Load port
      print(
          "Configuration chargée: id = $id, adresse = $adresse, port = $port");
    } catch (e) {
      print("Erreur lors du chargement de la configuration: $e");
    }
  }

  Future<void> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', id); // Save the id value
      await prefs.setString('adresse', adresse); // Save adresse
      await prefs.setString('port', port); // Save port
      print(
          "Configuration sauvegardée: id = $id, adresse = $adresse, port = $port");
    } catch (e) {
      print("Erreur lors de la sauvegarde de la configuration: $e");
    }
  }
}
  // Sauvegarder la configuration dans SharedPreferences
//   Future<void> saveConfig() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('adresse', adresse);
//       await prefs.setString('port', port);
//       print('Config saved: adresse = $adresse, port = $port'); // Log pour vérifier
//     } catch (e) {
//       print("Error saving config: $e");
//     }
//   }
// }
  // Charger la configuration depuis SharedPreferences
  // Future<void> loadConfig() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     adresse = prefs.getString('adresse') ?? '';
  //     port = prefs.getString('port') ?? '';
  //     print('Config loaded: adresse = $adresse, port = $port'); // Log pour vérifier
  //   } catch (e) {
  //     print("Error loading config: $e");
  //   }
  // }

  // class ConfigService {
//   static final ConfigService _instance = ConfigService._internal();
//   late Map<String, dynamic> _config;

//   factory ConfigService() {
//     return _instance;
//   }

//   ConfigService._internal();

//   Future<void> loadConfig() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/config.json');

//       if (file.existsSync()) {
//         final configString = await file.readAsString();
//         _config = json.decode(configString);
//       } else {
//         final configString = await rootBundle.loadString('assets/config.json');
//         _config = json.decode(configString);
//       }
//     } catch (e) {
//       print("Error loading config: $e");
//     }
//   }

//   Future<void> saveConfig() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/config.json');
//       await file.writeAsString(json.encode(_config));
//     } catch (e) {
//       print("Error saving config: $e");
//     }
//   }

//   String get adresse => _config['adresse'];
//   set adresse(String value) {
//     _config['adresse'] = value;
//   }

//   String get port => _config['port'];
//   set port(String value) {
//     _config['port'] = value;
//   }
// }