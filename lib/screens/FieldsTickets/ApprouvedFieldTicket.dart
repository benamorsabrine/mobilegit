import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';

class FieldApprouvedScreen extends StatefulWidget {
  final String token;
  final String? email;

  const FieldApprouvedScreen({super.key, required this.token, this.email});

  @override
  _FieldApprouvedScreenState createState() => _FieldApprouvedScreenState();
}

class _FieldApprouvedScreenState extends State<FieldApprouvedScreen> {
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
  //
  Future<void> fetchAssignedTickets() async {
    setState(() {
      isLoading = true;
    });
    var address = ConfigService().adresse;
    var port = ConfigService().port;

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
          // Obtenir la date d'aujourd'hui
          DateTime today = DateTime.now();
          DateTime startOfDay = DateTime(today.year, today.month, today.day);
          DateTime endOfDay = startOfDay.add(Duration(days: 1));

          setState(() {
            tickets = responseData.where((ticket) {
              DateTime ticketDate = DateTime.parse(ticket['createdAt']);
              return ticket['status'] == 'APPROVED' &&
                  ticketDate.isAfter(startOfDay) &&
                  ticketDate.isBefore(endOfDay);
            }).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tickets: $error');
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
          'Approuved Tickets',
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
                    'No ticket found.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Status: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(tickets[index]['status']),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Client: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(tickets[index]['client']['name']),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Agence: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(tickets[index]['agence']['agence']),
                                ],
                              ),
                            ]),
                      ),
                    );
                  },
                ),
    );
  }
}
