import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:todo/screens/tickets/ticketDetails.dart';

class PhoneAssignedScreen extends StatefulWidget {
  final String token;
  final String? email;

  const PhoneAssignedScreen({super.key, required this.token, this.email});

  @override
  _PhoneAssignedScreenState createState() => _PhoneAssignedScreenState();
}

class _PhoneAssignedScreenState extends State<PhoneAssignedScreen> {
  bool isLoading = false;
  List<dynamic> tickets = [];
  var address = ConfigService().adresse;
  var port = ConfigService().port;
  @override
  void initState() {
    super.initState();
    fetchAssignedTickets();
  }

  Future<void> fetchAssignedTickets() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/phone'),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            tickets = responseData
                .where((ticket) => ticket['status'] == 'ASSIGNED')
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
                      fetchAssignedTickets();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assigned',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
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
                    var ticket = tickets[index];
                    var technicien = ticket['technicien'];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(tickets[index]['reference']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketDetailScreenTech(
                                  ticketId: tickets[index]['id'], ticket: null,),
                            ),
                          );
                        },
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tickets[index]['status']),
                            if (technicien != null)
                              Text(
                                '${technicien['firstname'] ?? ''} ${technicien['lastname'] ?? ''}',
                              )
                            else
                              const Text('N/A'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
