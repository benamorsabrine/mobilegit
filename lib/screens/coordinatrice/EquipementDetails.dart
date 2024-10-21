import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final String equipementId;

  const EquipmentDetailScreen({super.key, required this.equipementId});

  @override
  _EquipmentDetailScreenState createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  Map<String, dynamic>? equipment;
  bool isLoading = true;
  bool hasError = false;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  @override
  void initState() {
    super.initState();
    fetchEquipmentDetails();
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  /*String formatDate(dynamic date) {
    // Vérifie si la date est nulle
    if (date == null) return 'Non rempli';

    // Si la date est une liste, on prend le premier élément si la liste n'est pas vide
    if (date is List) {
      date = date.isNotEmpty ? date[0] : null;
    }

    // Si la date est une chaîne de caractères, on essaie de la parser
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        // Formate la date et la retourne
        return Jiffy(parsedDate).yMMMMEEEEdjm;
      } catch (e) {
        // En cas d'erreur de parsing, retourne 'Non rempli'
        return 'Non rempli';
      }
    }

    // Retourne 'Non rempli' si la date n'est ni une chaîne de caractères ni une liste
    return 'Non rempli';
  }
*/
  Future<void> fetchEquipmentDetails() async {
    try {
      final response = await http
          .get(Uri.parse('$address:$port/api/equi/${widget.equipementId}'));

      if (response.statusCode == 200) {
        setState(() {
          equipment = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load equipment details');
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error fetching equipment details: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Equipment Details',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
        ),
        body: Container(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
                  ? const Center(child: Text('Error fetching equipment details'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Numéro Série: ${equipment!['numero_serie']}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'Client: ${equipment!['client']['name'] ?? 'Non rempli'}'),
                          Text(
                              'Agence: ${equipment!['agence']['agence'] ?? 'Non rempli'}'),
                          Text(
                              'Modele: ${equipment!['modele']['name'] ?? 'Non rempli'}'),
                          Text(
                              'Modéle écran: ${equipment!['modele']['modele_ecran'] ?? 'Non rempli'}'),
                          Text('Type: ${equipment!['type'] ?? 'Non rempli'}'),
                          /* Text(
                              'Date mise en service : ${formatDate(equipment!['date_mise_enservice'] ?? 'Non rempli')}'),
                          Text(
                              'Date installation physique : ${formatDate(equipment!['date_installation_physique'] ?? 'Non rempli')}'),
                          Text(
                              'Date Livraison : ${formatDate(equipment!['date_livraison'] ?? 'Non rempli')}'),
                          */
                          const Text(
                            'Autre données',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          Text(
                              'Nombre K7: ${equipment!['nb_casette'] ?? 'Non rempli'}'),
                          Text(
                              'Nombre caméra: ${equipment!['nb_camera'] ?? 'Non rempli'}'),
                          Text(
                              'Type caméra: ${equipment!['type_camera'] ?? 'Non rempli'}'),
                          Text(
                              'Modéle pc: ${equipment!['modele_pc'] ?? 'Non rempli'}'),
                          Text(
                              'Version Application: ${equipment!['version_application'] ?? 'Non rempli'}'),
                          Text(
                              'Version OS: ${equipment!['version_os'] ?? 'Non rempli'}'),
                          /*Text(
                              'Début garantie : ${formatDate(equipment!['garantie_start_date'] ?? 'Non rempli')}'),
                          Text(
                              'Fin garantie : ${formatDate(equipment!['garantie_end_date'] ?? 'Non rempli')}'),
                          Text(
                              'Début maintenance: ${formatDate(equipment!['date_debut_maintenance'] ?? 'Non rempli')}'),
                          Text(
                              'Fin maintenance : ${formatDate(equipment!['date_end_maintenance'] ?? 'Non rempli')}'),
                        */
                          Text(
                              'Geolocalisation : ${equipment!['geolocalisation'] ?? 'Non rempli'}'),
                          Text(
                              'Sous adressse: ${equipment!['sous_adresse'] ?? 'Non rempli'}'),
                          Text(
                              'Type Branche: ${equipment!['branch_type'] ?? 'Non rempli'}'),
                          Text(
                              'Code QR: ${equipment!['codeqrequipement'] ?? 'Non rempli'}'),
                          const SizedBox(height: 8),
                          const Text(
                            'Paramétres réseau',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          Text(
                              'Code terminal: ${equipment!['code_terminal'] ?? 'Non rempli'}'),
                          Text(
                              'Adresse IP : ${equipment!['adresse_ip'] ?? 'Non rempli'}'),
                          Text(
                              'Masque de sous réseaux : ${equipment!['masque_sous_reseau'] ?? 'Non rempli'}'),
                          Text(
                              'Getway : ${equipment!['getway'] ?? 'Non rempli'}'),
                          Text(
                              'Adresse IP serveur monétique : ${equipment!['adresse_ip_serveur_monetique'] ?? 'Non rempli'}'),
                          Text('Port : ${equipment!['port'] ?? 'Non rempli'}'),
                          Text('TMK I : ${equipment!['tmk1'] ?? 'Non rempli'}'),
                          Text(
                              'TMK II : ${equipment!['tmk2'] ?? 'Non rempli'}'),
                          const Text(
                            'Configuration des cassettes',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          Text(
                              'Type A: ${equipment!['config_k7_typeA'] ?? 'Non rempli'}'),
                          Text(
                              'Type B : ${equipment!['config_k7_typeB'] ?? 'Non rempli'}'),
                          Text(
                              'Type C : ${equipment!['config_k7_typeC'] ?? 'Non rempli'}'),
                          Text(
                              'Type D : ${equipment!['config_k7_typeD'] ?? 'Non rempli'}'),
                        ],
                      ),
                    ),
        ));
  }
}
