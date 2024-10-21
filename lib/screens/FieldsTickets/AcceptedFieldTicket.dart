import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/FieldsTickets/EnRouteFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/ReportedFieldTicket.dart';
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:todo/screens/tickets/ticketDetails.dart';
import 'package:intl/intl.dart';

class FieldAcceptedScreen extends StatefulWidget {
  final String token;
  final String? email;

  const FieldAcceptedScreen({super.key, required this.token, this.email});

  @override
  _FieldAcceptedScreenState createState() => _FieldAcceptedScreenState();
}

class _FieldAcceptedScreenState extends State<FieldAcceptedScreen> {
  final ConfigService configService = ConfigService();
  bool isLoading = false;
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    fetchAssignedTickets();
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> fetchAssignedTickets() async {
    var address = ConfigService().adresse;
    var port = ConfigService().port;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticketht/assigned/field'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            tickets = responseData
                .where((ticket) => ticket['status'] == 'ACCEPTED')
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching alerts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // String formatDate(String dateString) {
  //   DateTime parsedDate = DateTime.parse(dateString);
  //   String formattedDate = DateFormat('dd,MM,yyyy').format(parsedDate);
  //   String formattedTime = DateFormat('HH:mm:ss').format(parsedDate);
  //   return '$formattedDate ';
  // }

  // String formatTime(String dateString) {
  //   DateTime parsedDate = DateTime.parse(dateString);
  //   String formattedDate = DateFormat('dd,MM,yyyy').format(parsedDate);
  //   String formattedTime = DateFormat('HH:mm:ss').format(parsedDate);
  //   return '$formattedTime';
  // }

  Future<void> handleReportTicket(String ticketId) async {
    String reportingNoteAssigned =
        ''; // Variable pour stocker la raison du report

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reporting Ticket ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Pourquoi voulez-vous reporter le ticket ?'),
              TextField(
                onChanged: (value) {
                  reportingNoteAssigned =
                      value; // Met à jour la raison du report à chaque changement
                },
                decoration: const InputDecoration(
                  hintText: 'Raison du report',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Annule l'action de report
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (reportingNoteAssigned.trim().isEmpty) {
                  // Affiche un message d'erreur si le champ est vide
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Attention'),
                        content: const Text(
                            'Le champ de raison du report est requis.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return; // Arrête l'exécution si le champ est vide
                }
                Navigator.of(context).pop(true); // Confirme l'action de report
                try {
                  final response = await http.put(
                    Uri.parse(
                        '$address:$port/api/ticket/ReportingField/$ticketId'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'status': 'REPORTED',
                      'reporting_note_assigned': reportingNoteAssigned,
                      'reporting_assignedTicket_time':
                          DateTime.now().toIso8601String(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Reporté avec succès!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FieldEnRouteScreen(
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    throw Exception('Échec du report du ticket');
                  }
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Erreur lors du report"),
                        content: const Text("Veuillez réessayer plus tard"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Reporter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleAcceptTicket(String ticketId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Êtes-vous sûr  de partir ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Oui, je vais partir'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final response = await http.put(
          Uri.parse('$address:$port/api/ticket/depart/$ticketId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'status': 'GOING',
            'departure_time': DateTime.now().toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Partis avec succès, Bonne route!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FieldEnRouteScreen(
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Erreur ticket"),
                content: const Text("Veuillez réessayer plus tard"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Erreur "),
              content: const Text("Veuillez réessayer plus tard"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accepted Tickets',
          style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAssignedTickets,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? const Center(
                  child: Text(
                    'No assigned tickets found.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: const Color.fromRGBO(231, 236, 250, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                tickets[index]['reference'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Color.fromRGBO(50, 50, 50, 1),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildClientInfo(tickets[index]),
                                  _buildDateAndNote(tickets[index]),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TicketDetailScreenTech(
                                      ticketId: tickets[index]['_id'],
                                      ticket: null,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButtons(tickets[index]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildClientInfo(Map<String, dynamic> ticket) {
    print('Help desk : ${ticket['technicien_transfer']}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          "Client: ",
          ticket['client'] is Map && ticket['client']['name'] != null
              ? ticket['client']['name']
              : ticket['client'] ?? 'Non spécifié', // Valeur par défaut
        ),
        _buildRow(
          "Agence: ",
          ticket['agence'] is Map && ticket['agence']['agence'] != null
              ? ticket['agence']['agence']
              : ticket['agence'] ?? 'Non spécifié', // Valeur par défaut
        ),
        _buildRow(
          "Help Desk: ",
          ticket['technicien_transfer'] is Map
              ? "${ticket['technicien_transfer']['firstname']} ${ticket['technicien_transfer']['lastname']}"
              : 'Non spécifié',
        ),
      ],
    );
  }

  Widget _buildDateAndNote(Map<String, dynamic> ticket) {
    print('Date de transfert: ${ticket['accepting_time']}');
    return Column(
      children: [
        _buildRow("Note: ", ticket['note'] ?? 'N/A'),
        _buildRow(
            "Date d'accept: ", formatDate(ticket['accepting_time'])),
        _buildRow(
            "Heure d'accept : ", formatTime(ticket['accepting_time'])),
      ],
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString == 'N/A') {
      return 'N/A'; // Si la date est absente ou invalide, renvoyer 'N/A'
    }
    try {
      DateTime? parsedDate = DateTime.tryParse(dateString);
      if (parsedDate == null) {
        return 'N/A'; // Si parsing échoue, renvoyer 'N/A'
      }
      return DateFormat('dd/MM/yyyy')
          .format(parsedDate); // Format du jour/mois/année
    } catch (e) {
      return 'N/A'; // Si une erreur se produit pendant le parsing, renvoyer 'N/A'
    }
  }

  String formatTime(String? dateString) {
    if (dateString == null || dateString == 'N/A') {
      return 'N/A'; // Si l'heure est absente ou invalide, renvoyer 'N/A'
    }
    try {
      DateTime? parsedDate = DateTime.tryParse(dateString);
      if (parsedDate == null) {
        return 'N/A'; // Si parsing échoue, renvoyer 'N/A'
      }
      return DateFormat('HH:mm:ss')
          .format(parsedDate); // Format des heures/minutes/secondes
    } catch (e) {
      return 'N/A'; // Si une erreur se produit pendant le parsing, renvoyer 'N/A'
    }
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color.fromRGBO(52, 52, 52, 1),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 102, 102, 102),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> ticket) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 30),
          ElevatedButton.icon(
            onPressed: () {
              handleReportTicket(ticket['_id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 122, 122, 122),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            icon: const Icon(Icons.report, color: Colors.white),
            label: const Text(
              'Report',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 25),
          ElevatedButton.icon(
            onPressed: () {
              handleAcceptTicket(ticket['_id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF61C0BF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            icon: const Icon(Icons.directions_car, color: Colors.white),
            label: const Text(
              'Depart',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10), // Spacing between buttons
        ],
      ),
    );
  }
}
