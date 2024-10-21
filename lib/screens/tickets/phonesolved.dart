import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';

import 'package:todo/screens/tickets/ticketDetails.dart';

class PhoneSolvedScreen extends StatefulWidget {
  final String token;
  final String? email;

  const PhoneSolvedScreen({super.key, required this.token, this.email});
  @override
  _PhoneSolvedScreenState createState() => _PhoneSolvedScreenState();
}

class _PhoneSolvedScreenState extends State<PhoneSolvedScreen> {
  bool isLoading = false;
  List<dynamic> tickets = [];
  @override
  void initState() {
    super.initState();
    fetchAssignedTickets();
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> fetchAssignedTickets() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticketht/assigned/phone'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            tickets = responseData
                .where((ticket) => ticket['status'] == 'COMPLETED')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Completed Tickets',
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
                    'No completed tickets found.',
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
                              title: Row(
                                children: [
                                  const Text(
                                    "Ticket Number: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color.fromRGBO(50, 50, 50, 1),
                                    ),
                                  ),
                                  Text(
                                    tickets[index]['reference'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color.fromRGBO(50, 50, 50, 1),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildClientInfo(tickets[index]),
                                  //  _buildDateAndNote(tickets[index]),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          "Client: ",
          ticket['client'] is Map && ticket['client']['name'] != null
              ? ticket['client']['name']
              : 'Non spécifié',
        ),
        _buildRow(
          "Agence: ",
          ticket['agence'] is Map && ticket['agence']['agence'] != null
              ? ticket['agence']['agence']
              : 'Non spécifié',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contacts: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ticket['agence'] is Map &&
                      ticket['agence']['contacts'] != null &&
                      ticket['agence']['contacts'] is List &&
                      ticket['agence']['contacts'].isNotEmpty
                  ? Column(
                      children: List.generate(
                          ticket['agence']['contacts'].length, (index) {
                        var contact = ticket['agence']['contacts'][index];
                        return contact is Map &&
                                contact['name'] != null &&
                                contact['phone'] != null
                            ? Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 16, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    "${contact['name']}: ${contact['phone']}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              )
                            : Text('Contact incomplet');
                      }),
                    )
                  : Text('Non spécifié'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndNote(Map<String, dynamic> ticket) {
    print('Aiisgned time: ${ticket['solving_time']}');
    return Column(
      children: [
        _buildRow("Note: ", ticket['note'] ?? 'N/A'),
        _buildRow("Completed Date: ", formatDate(ticket['solving_time'])),
        _buildRow("Completed Hour: ", formatTime(ticket['solving_time'])),
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



  Widget _buildActionButtons(Map<String, dynamic> ticket) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
              width: 30), // Peut être ajusté ou supprimé selon le besoin
          const SizedBox(
              width: 25), // Peut être ajusté ou supprimé selon le besoin
          SizedBox(
            width:
                170, // Ajuste la largeur pour s'assurer que le texte tient sur une ligne
            child: ElevatedButton(
              onPressed: () {
                String ticketId =
                    ticket['_id']; // Correction ici pour accéder au bon ticket
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 176, 190, 173),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical:
                      5, // Ajuste la valeur pour réduire le padding vertical
                  horizontal:
                      8, // Ajuste la valeur pour réduire le padding horizontal
                ),
              ),
              child: const Text(
                'Waiting for validation ..',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                overflow:
                    TextOverflow.ellipsis, // Tronque le texte s'il dépasse
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text(
  //         'Completed Tickets',
  //         style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
  //       ),
  //       backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
  //       toolbarHeight: 60,
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.refresh),
  //           onPressed: fetchAssignedTickets,
  //         ),
  //       ],
  //     ),
  //     body: isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : tickets.isEmpty
  //             ? const Center(
  //                 child: Text(
  //                   'No solved tickets found.',
  //                   style: TextStyle(fontSize: 20),
  //                 ),
  //               )
  //             : ListView.builder(
  //                 itemCount: tickets.length,
  //                 itemBuilder: (context, index) {
  //                   return Card(
  //                       margin: const EdgeInsets.all(10),
  //                       child: ListTile(
  //                         title: Text(tickets[index]['reference']),
  //                         onTap: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => TicketDetailScreenTech(
  //                                 ticketId: tickets[index]['_id'],
  //                                 ticket: null,
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                         subtitle: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(tickets[index]['status']),
  //                           ],
  //                         ),
  //                         trailing: SizedBox(
  //                           width:
  //                               170, // Ajuste la largeur pour s'assurer que le texte tient sur une ligne
  //                           child: ElevatedButton(
  //                             onPressed: () {
  //                               String ticketId = tickets[index]['_id'];
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor:
  //                                   const Color.fromARGB(255, 176, 190, 173),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical:
  //                                     5, // Ajuste la valeur pour réduire le padding vertical
  //                                 horizontal:
  //                                     8, // Ajuste la valeur pour réduire le padding horizontal
  //                               ),
  //                             ),
  //                             child: const Text(
  //                               'Waiting for validation ..',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 12,
  //                               ),
  //                               overflow: TextOverflow
  //                                   .ellipsis, // Tronque le texte s'il dépasse
  //                             ),
  //                           ),
  //                         ),
  //                       ));
  //                 },
  //               ),
  //   );
  // }

