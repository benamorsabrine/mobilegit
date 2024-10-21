import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/tickets/ticketDetails.dart';
import 'package:todo/screens/config/config_service.dart';

class HistoriqueManagerScreen extends StatefulWidget {
  final String token;
  const HistoriqueManagerScreen({super.key, required this.token});

  @override
  _HistoriqueManagerScreenState createState() =>
      _HistoriqueManagerScreenState();
}

class _HistoriqueManagerScreenState extends State<HistoriqueManagerScreen> {
  List<dynamic> historique = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistorique();
  }

    var address = ConfigService().adresse;
    var port = ConfigService().port;
  Future<void> fetchHistorique() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticketht/manager/all'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            historique = responseData;
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
          'Manager Historique ',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
        toolbarHeight: 60,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : historique.isEmpty
                ? const Center(child: Text('No historique found'))
                : ListView.builder(
                    itemCount: historique.length,
                    itemBuilder: (context, index) {
                      final historiques = historique[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              'Numéro Ticket: ${historiques['reference']}'),
                          /*onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    //TicketDetailScreen(ticket: historiques),
                              ),
                            );
                          },*/
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type Ticket: ${historiques['type']}'),
                              Text(
                                  'service_station: ${historiques['service_station']}'),
                              Text('solution: ${historiques['solution']}'),
                              Text(
                                  'solving time: ${historiques['solving_time']}'),
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
