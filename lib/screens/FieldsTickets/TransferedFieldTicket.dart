import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:todo/screens/FieldsTickets/AcceptedFieldTicket.dart';
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:todo/screens/tickets/ticketDetails.dart';

class FieldTransferedScreen extends StatefulWidget {
  final String token;
  final String? email;

  const FieldTransferedScreen({super.key, required this.token, this.email});

  @override
  _FieldTransferedScreenState createState() => _FieldTransferedScreenState();
}

class _FieldTransferedScreenState extends State<FieldTransferedScreen> {
  final ConfigService configService = ConfigService();
  bool isLoading = false;
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    fetchTransferedTickets();
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> fetchTransferedTickets() async {
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
                .where((ticket) =>
                    ticket['status'] != null &&
                    ticket['status'] == 'TRANSFERED')
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

  Future<void> handleAcceptTicket(String ticketId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Êtes-vous sûr de vouloir accepter ce ticket ?'),
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
              child: const Text('Oui, accepter'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final response = await http.put(
          Uri.parse('$address:$port/api/ticket/accepted/$ticketId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'status': 'ACCEPTED'}),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Ticket accepté avec succès!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FieldAcceptedScreen(
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
                title: const Text("Erreur lors de l'acceptation du ticket"),
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
              title: const Text("Erreur lors de l'acceptation du ticket"),
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text(
  //         'Transfered',
  //         style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
  //       ),
  //       backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
  //       toolbarHeight: 60,
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.refresh),
  //           onPressed: fetchTransferedTickets,
  //         ),
  //       ],
  //     ),
  //     body: isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : tickets.isEmpty
  //             ? const Center(
  //                 child: Text(
  //                   'No Transfered tickets found.',
  //                   style: TextStyle(fontSize: 20),
  //                 ),
  //               )
  //             : ListView.builder(
  //                 itemCount: tickets.length,
  //                 itemBuilder: (context, index) {
  //                   final ticket = tickets[index];
  //                   return SizedBox(
  //                     height: 150, // Define the desired height
  //                     child: Card(
  //                       margin: const EdgeInsets.all(10),
  //                       child: ListTile(
  //                         contentPadding: const EdgeInsets.all(
  //                             12), // Padding inside ListTile
  //                         title: Text(
  //                           ticket['reference'] ?? 'N/A',
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.w600, // Font weight
  //                             fontSize: 18, // Font size
  //                           ),
  //                         ),
  //                         onTap: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => TicketDetailScreenTech(
  //                                 ticketId: ticket['_id'],
  //                                 ticket: null,
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                         subtitle: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 const Text(
  //                                   "Status: ",
  //                                   style: TextStyle(
  //                                     fontWeight:
  //                                         FontWeight.bold, // Font weight
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   ticket['status'] ?? 'N/A',
  //                                   style: const TextStyle(
  //                                     color: Color.fromARGB(
  //                                         255, 102, 102, 102), // Text color
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             Row(
  //                               children: [
  //                                 const Text(
  //                                   "Client: ",
  //                                   style: TextStyle(
  //                                     fontWeight:
  //                                         FontWeight.bold, // Font weight
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   ticket['client']['name'] ?? 'N/A',
  //                                 ),
  //                               ],
  //                             ),
  //                             Row(
  //                               children: [
  //                                 const Text(
  //                                   "Agenc: ",
  //                                   style: TextStyle(
  //                                     fontWeight:
  //                                         FontWeight.bold, // Font weight
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   ticket['agence']['agence'] ?? 'N/A',
  //                                 ),
  //                               ],
  //                             ),
  //                             Row(
  //                               children: [
  //                                 const Text(
  //                                   "Phone Techncien: ",
  //                                   style: TextStyle(
  //                                     fontWeight:
  //                                         FontWeight.bold, // Font weight
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   ticket['technicien']['firstname'] ?? 'N/A',
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                         trailing: ElevatedButton(
  //                           onPressed: () {
  //                             handleAcceptTicket(ticket['_id']);
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: const Color.fromARGB(
  //                                 255, 171, 4, 4), // Button color
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(
  //                                   10), // Rounded button corners
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             'Accept',
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfered Tickets',
          style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTransferedTickets,
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
    print('Phone techncien : ${ticket['technicien_transfer']}');
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
          "Help desk: ",
          ticket['technicien'] is Map //technicien twali
              ? "${ticket['technicien']['firstname']} ${ticket['technicien']['lastname']}"
              : 'Non spécifié',
        ),
      ],
    );
  }

  Widget _buildDateAndNote(Map<String, dynamic> ticket) {
    print('Transfering time: ${ticket['transfering_time']}');
    return Column(
      children: [
        _buildRow("Note du transfert: ", ticket['note'] ?? 'N/A'),
        //   _buildRow("Date: ", formatDate(ticket['transfering_time'])),
        //   _buildRow("Heure: ", formatTime(ticket['transfering_time'])),
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 30),
          ElevatedButton.icon(
            onPressed: () {
              handleAcceptTicket(ticket['_id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB6B9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            icon: const Icon(Icons.done, color: Colors.white),
            label: const Text(
              'Accept',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
