import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';

class ListeAgenceScreen extends StatefulWidget {
  final String token;
  final String clientId;
  final String clientName;

  const ListeAgenceScreen(
      {super.key, required this.token, required this.clientId, required this.clientName});

  @override
  _ListeAgenceScreenState createState() => _ListeAgenceScreenState();
}

class _ListeAgenceScreenState extends State<ListeAgenceScreen> {
  List<dynamic> agences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAgences();
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;

  Future<void> fetchAgences() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/client/${widget.clientId}/agences'),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            agences = responseData;
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
        title: Text(
          '${widget.clientName} Agences',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAgences,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agences.isEmpty
              ? const Center(child: Text('No agences found'))
              : RefreshIndicator(
                  onRefresh: fetchAgences,
                  child: ListView.builder(
                    itemCount: agences.length,
                    itemBuilder: (context, index) {
                      final agence = agences[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agence['agence'] ?? 'Non rempli',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  'Adresse: ${agence['adresse'] ?? 'Non rempli'}'),
                              Text(
                                  'Localisation: ${agence['localisation'] ?? 'Non rempli'}'),
                              const SizedBox(height: 8),
                              // Contacts list
                              const Text(
                                'Contacts:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: agence['contacts']?.length ?? 0,
                                itemBuilder: (context, contactIndex) {
                                  final contact =
                                      agence['contacts'][contactIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Name: ${contact['name'] ?? 'Non rempli'}'),
                                        Text(
                                            'Phone: ${contact['phone'] ?? 'Non rempli'}'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
