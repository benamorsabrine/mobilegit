import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:todo/screens/coordinatrice/listeAgence.dart';
import 'package:todo/screens/coordinatrice/equipementDetails.dart';

class ListeEquipementScreen extends StatefulWidget {
  final String token;

  const ListeEquipementScreen({super.key, required this.token});

  @override
  _ListeEquipementScreenState createState() => _ListeEquipementScreenState();
}

class _ListeEquipementScreenState extends State<ListeEquipementScreen> {
  List<dynamic> equipements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/equi/list'),
      );
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
        throw Exception('Failed to load alertes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching alerts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Equipements',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchClients,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : equipements.isEmpty
              ? const Center(child: Text('No clients found'))
              : RefreshIndicator(
                  onRefresh:
                      fetchClients, // Call fetchClients instead of fetchAlertes
                  child: ListView.builder(
                    itemCount: equipements.length,
                    itemBuilder: (context, index) {
                      final equipement =
                          equipements[index]; // Fetch individual client
                      return Card(
                        child: ListTile(
                          title: Text(
                              'Numero série: ${equipement['numero_serie'] ?? 'N/A'}'), // Serial number as title
                          subtitle: Column(
                            // Add other details below the title
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${equipement['type'] ?? 'N/A'}'),
                              Text(
                                  'Client: ${equipement['client']['name'] ?? 'N/A'}'), // Model details
                              Text(
                                  'Agence: ${equipement['agence']['agence'] ?? 'N/A'}'), // Location details
                            ],
                          ),
                          trailing: const Icon(Icons.info_outline),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EquipmentDetailScreen(
                                  equipementId: equipement[
                                      '_id'], // Pass the equipment ID or relevant data
                                ),
                              ),
                            );
                          }, // Add an icon at the end
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
