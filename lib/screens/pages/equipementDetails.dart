import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:intl/intl.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final String equipmentId;

  const EquipmentDetailScreen({super.key, required this.equipmentId});

  @override
  _EquipmentDetailScreenState createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  final ConfigService configService = ConfigService();
  Map<String, dynamic>? equipment;
  bool isLoading = true;
  bool hasError = false;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  var address = ConfigService().adresse;
  var port = ConfigService().port;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    fetchEquipmentDetails();
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  Future<void> fetchEquipmentDetails() async {
    var address = ConfigService().adresse;
    var port = ConfigService().port;
    try {
      final response = await http
          .get(Uri.parse('$address:$port/api/equi/${widget.equipmentId}'));

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

  String formatDate(dynamic date) {
    if (date == null) return 'Non rempli';

    if (date is List) {
      date = date.isNotEmpty ? date[0] : null;
    }

    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        final day = parsedDate.day.toString().padLeft(2, '0');
        final month = parsedDate.month.toString().padLeft(2, '0');
        final year = parsedDate.year.toString();

        // Exemple de format: 01 Janvier 2024
        final formattedDate = '$day ${getMonthName(parsedDate.month)} $year';
        return formattedDate;
      } catch (e) {
        return 'Non rempli';
      }
    }

    return 'Non rempli';
  }

  String getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails equipement',
            style: TextStyle(
              color: Color.fromRGBO(209, 77, 90, 1),
            )),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text(
                      'Erreur lors de la récupération des détails de l\'équipement',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Informations de Base', Icons.info),
                        _buildInfoRow(
                            'Numéro de Série', equipment!['numero_serie']),
                        _buildInfoRow('Modèle Écran',
                            equipment!['modele']['modele_ecran']),
                        _buildInfoRow('Type', equipment!['type']),
                        const SizedBox(height: 20),
                        _buildSectionTitle(
                            'Paramètres Réseau', Icons.network_check),
                        _buildInfoRow(
                            'Code Terminal', equipment!['code_terminal']),
                        _buildInfoRow('Adresse IP', equipment!['adresse_ip']),
                        _buildInfoRow('Masque de Sous Réseaux',
                            equipment!['masque_sous_reseau']),
                        _buildInfoRow('Gateway', equipment!['getway']),
                        _buildInfoRow('Adresse IP Serveur Monétique',
                            equipment!['adresse_ip_serveur_monetique']),
                        _buildInfoRow('Port', equipment!['port']),
                        _buildInfoRow('TMK I', equipment!['tmk1']),
                        _buildInfoRow('TMK II', equipment!['tmk2']),
                        const SizedBox(height: 20),
                        _buildSectionTitle(
                            'Configuration des Cassettes', Icons.settings),
                        _buildInfoRow('Type A', equipment!['config_k7_typeA']),
                        _buildInfoRow('Type B', equipment!['config_k7_typeB']),
                        _buildInfoRow('Type C', equipment!['config_k7_typeC']),
                        _buildInfoRow('Type D', equipment!['config_k7_typeD']),
                        _buildSectionTitle('Autres Données', Icons.data_usage),
                        _buildInfoRow('Nombre K7', equipment!['nb_casette']),
                        _buildInfoRow('Nombre Caméra', equipment!['nb_camera']),
                        _buildInfoRow('Type Caméra', equipment!['type_camera']),
                        _buildInfoRow('Modèle PC', equipment!['modele_pc']),
                        _buildInfoRow('Version Application',
                            equipment!['version_application']),
                        _buildInfoRow('Version OS', equipment!['version_os']),
                        _buildInfoRow(
                            'Géolocalisation', equipment!['geolocalisation']),
                        _buildInfoRow(
                            'Sous Adresse', equipment!['sous_adresse']),
                        _buildInfoRow(
                            'Type Branche', equipment!['branch_type']),
                        _buildInfoRow(
                            'Code QR', equipment!['codeqrequipement']),
                        // const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    String displayValue;
    if (value is int) {
      displayValue = value.toString();
    } else if (value is String) {
      displayValue = value;
    } else {
      displayValue = 'Non rempli';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color.fromARGB(255, 56, 56, 56),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
