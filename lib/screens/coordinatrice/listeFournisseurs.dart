import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';

class ListeFournisseurscreen extends StatefulWidget {
  final String token;

  const ListeFournisseurscreen({super.key, required this.token});

  @override
  _ListeFournisseurscreenScreenState createState() =>
      _ListeFournisseurscreenScreenState();
}

class _ListeFournisseurscreenScreenState extends State<ListeFournisseurscreen> {
  List<dynamic> fournisseurs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFournisseurs();
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;

  Future<void> fetchFournisseurs() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/marque/list'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          setState(() {
            fournisseurs = responseData;
          });
        } else {
          setState(() {
            fournisseurs = [];
          });
        }
      } else {
        throw Exception('Failed to load fournisseurs: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching fournisseurs: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchModeles(String marqueId) async {
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/marque/$marqueId/modeles'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load modeles: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching modeles: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fournisseurs',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFournisseurs,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fournisseurs.isEmpty
              ? const Center(child: Text('No Fournisseurs found'))
              : RefreshIndicator(
                  onRefresh: fetchFournisseurs,
                  child: ListView.builder(
                    itemCount: fournisseurs.length,
                    itemBuilder: (context, index) {
                      final fournisseur = fournisseurs[index];

                      return Card(
                        child: ExpansionTile(
                          title: Text(fournisseur['name'] ?? 'Unknown Name'),
                          childrenPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          onExpansionChanged: (bool expanded) async {
                            if (expanded) {
                              final String? fournisseurId = fournisseur['_id'];
                              if (fournisseurId != null) {
                                final Map<String, dynamic> updatedFournisseur =
                                    Map<String, dynamic>.from(fournisseur);

                                setState(() {
                                  updatedFournisseur['isLoadingModeles'] = true;
                                  fournisseurs[index] = updatedFournisseur;
                                });

                                List<dynamic> modeles =
                                    await fetchModeles(fournisseurId);

                                setState(() {
                                  updatedFournisseur['modeles'] = modeles;
                                  updatedFournisseur['isLoadingModeles'] =
                                      false;
                                  fournisseurs[index] = updatedFournisseur;
                                });
                              } else {
                                print('Invalid fournisseur id');
                              }
                            }
                          },
                          children: fournisseur['isLoadingModeles'] == true
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  )
                                ]
                              : fournisseur['modeles'] != null &&
                                      fournisseur['modeles'].isNotEmpty
                                  ? fournisseur['modeles']
                                      .map<Widget>((modele) => ListTile(
                                            title: Text(
                                                "Modele: ${modele['name'] ?? 'Unknown Model'}"),
                                            subtitle: Text(
                                                "Screen Type: ${modele['modele_ecran'] ?? 'Unknown Screen Type'}"),
                                          ))
                                      .toList()
                                  : [
                                      const ListTile(
                                          title: Text('No modeles available'))
                                    ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
