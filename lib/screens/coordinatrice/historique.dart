import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/tickets/ticketDetails.dart';
import 'package:todo/screens/config/config_service.dart';

class HistoriqueScreen extends StatefulWidget {
  final String token;
  const HistoriqueScreen({super.key, required this.token});

  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> phoneApprovedHistorique = [];
  List<dynamic> fieldApprovedHistorique = [];
  bool isPhoneApprovedLoading = true;
  bool isFieldApprovedLoading = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //fetchHistorique('phone');
    //fetchHistorique('field');
    fetchAssignedTickets();
    fetchAssignedFieldTickets();
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;

  Future<void> fetchAssignedFieldTickets() async {
    setState(() {
      isFieldApprovedLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/solved'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            fieldApprovedHistorique = responseData
                .where((ticket) =>
                    ticket['status'] == 'APPROVED' && ticket['type'] == 'FIELD')
                .toList();
            isFieldApprovedLoading = false;
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
        isFieldApprovedLoading = false;
      });
    }
  }

  Future<void> fetchAssignedTickets() async {
    setState(() {
      isPhoneApprovedLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/solved'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            phoneApprovedHistorique = responseData
                .where((ticket) =>
                    ticket['status'] == 'APPROVED' && ticket['type'] == 'PHONE')
                .toList();
            isPhoneApprovedLoading = false;
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
        isPhoneApprovedLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique',
          style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Phone Approved'),
            Tab(text: 'Field Approved'),
          ],
          labelColor: Colors.white, // Color for selected tab text
          unselectedLabelColor: Colors.white54, // Color for unselected tab text
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoriqueList(phoneApprovedHistorique, isPhoneApprovedLoading),
          _buildHistoriqueList(fieldApprovedHistorique, isFieldApprovedLoading),
        ],
      ),
    );
  }

  Widget _buildHistoriqueList(List<dynamic> historique, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historique.isEmpty
              ? const Center(child: Text('No historique found'))
              : ListView.builder(
                  itemCount: historique.length,
                  itemBuilder: (context, index) {
                    final histItem = historique[index];
                    var technicien = histItem['technicien'];
                    var technicienTransfer = histItem['technicien_transfer'];
                    var technicien2 = histItem['technicien2'];
                    return Card(
                      child: ListTile(
                        title: Text('Numéro Ticket: ${histItem['reference']}'),
                        /* onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TicketDetailScreen(ticket: historiques),
                            ),
                          );
                        },*/
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Client: ${histItem['client']['name']}'),
                            Text('Type Ticket: ${histItem['type']}'),
                            Text('Status: ${histItem['status']}'),
                            if (technicien != null)
                              Text(
                                'Helpdesk : ${technicien['firstname'] ?? ''} ${technicien['lastname'] ?? ''}',
                              ),
                            if (technicien2 != null)
                              Text(
                                'Technicien :${technicien2['firstname'] ?? ''} ${technicien2['lastname'] ?? ''}',
                              ),
                            if (technicienTransfer != null)
                              Text(
                                'transféré au technicien : ${technicienTransfer['firstname'] ?? ''} ${technicienTransfer['lastname'] ?? ''}',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
