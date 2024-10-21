import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/pages/equipementDetails.dart';
import 'package:todo/screens/config/config_service.dart';

class EquipementScreen extends StatefulWidget {
  const EquipementScreen({super.key});

  @override
  _EquipementScreenState createState() => _EquipementScreenState();
}

class _EquipementScreenState extends State<EquipementScreen> {
  final ConfigService configService = ConfigService();
  List<dynamic> equipements = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    _loadConfiguration();
    fetchEquipements();
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  Future<void> fetchEquipements() async {
    var address = ConfigService().adresse;
    var port = ConfigService().port;
    try {
      final response =
          await http.get(Uri.parse('$address:$port/api/equi/list'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            equipements = responseData;
            isLoading = false;
          });
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to load equipements: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching equipements: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipements',
            style: TextStyle(
              color: Color.fromRGBO(209, 77, 90, 1),
            )),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: equipements.length,
                itemBuilder: (context, index) {
                  final equipement = equipements[index];

                  return GestureDetector(
                    onTap: () {
                      if (equipement != null && equipement['_id'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EquipmentDetailScreen(
                                equipmentId: equipement['_id']),
                          ),
                        );
                      } else {
                        print('Error: Equipment ID is null');
                      }
                    },
                    child: SizedBox(
                      width: 400,
                      height: 210,
                      child: Card(
                        color: const Color(
                            0xFFF9F9F9), // Couleur de fond moderne et claire
                        elevation:
                            8, // Élévation plus élevée pour un effet d'ombre plus marqué
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Coins plus arrondis pour un effet moderne
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons
                                    .devices, // Icône moderne pour représenter l'équipement
                                size: 40,
                                color: const Color.fromRGBO(209, 77, 90,
                                    1), // Couleur de l'icône pour un contraste vif
                              ),
                              const SizedBox(
                                  width:
                                      16), // Espace entre l'icône et le texte
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Numéro de Série: ${equipement['numero_serie'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                            0xFF333333), // Couleur du texte moderne
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Type: ${equipement['type'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            0xFF666666), // Couleur du texte pour une hiérarchie visuelle
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Marque: ${equipement['marque'] ?? 'N/A'}', // Correction du champ pour une information supplémentaire
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Modèle: ${equipement['modele'] ?? 'N/A'}', // Correction du champ pour une information supplémentaire
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
