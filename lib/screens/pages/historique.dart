import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/config/config_service.dart';
import 'package:intl/intl.dart';
import 'package:todo/screens/coordinatrice/phoneTicketsCoordinatrice/ticketDetails.dart';
import 'package:todo/screens/tickets/ticketDetails.dart';

class HistoriqueScreen extends StatefulWidget {
  final String token;
  const HistoriqueScreen({super.key, required this.token});

  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen>
    with SingleTickerProviderStateMixin {
  final ConfigService configService = ConfigService();
  late TabController _tabController;
  List<dynamic> phoneApprovedHistorique = [];
  List<dynamic> fieldApprovedHistorique = [];
  bool isPhoneApprovedLoading = true;
  bool isFieldApprovedLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConfiguration();
    fetchAssignedTickets();
    fetchAssignedFieldTickets();
  }

  String formatDate(String isoDate) {
    DateTime parsedDate = DateTime.parse(isoDate);
    // Format date as 'dd/MM/yyyy HH:mm'
    return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate.toLocal());
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig();
    setState(() {});
  }

  Future<void> fetchAssignedFieldTickets() async {
    setState(() {
      isFieldApprovedLoading = true;
    });

    var address = ConfigService().adresse;
    var port = ConfigService().port;

    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/field'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null) {
          final today = DateTime.now();

          setState(() {
            fieldApprovedHistorique = responseData
                .where((ticket) => ticket['status'] == 'VALIDATED')
                .where((ticket) {
              if (ticket['solving_time'] != null) {
                final createdAt = DateTime.tryParse(ticket['solving_time']);
                if (createdAt != null) {
                  return createdAt.year == today.year &&
                      createdAt.month == today.month &&
                      createdAt.day == today.day;
                }
              }
              return false;
            }).toList();

            isFieldApprovedLoading = false;
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
        isFieldApprovedLoading = false;
      });
    }
  }

  Future<void> fetchAssignedTickets() async {
    setState(() {
      isPhoneApprovedLoading = true;
    });
    var address = ConfigService().adresse;
    var port = ConfigService().port;

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
          final today = DateTime.now();
          setState(() {
            phoneApprovedHistorique = responseData
                .where((ticket) => ticket['status'] == 'VALIDATED')
                .where((ticket) {
              final solvedAt = DateTime.parse(ticket['created_at']);
              return solvedAt.year == today.year &&
                  solvedAt.month == today.month &&
                  solvedAt.day == today.day;
            }).toList();
            isPhoneApprovedLoading = false;
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
          tabs: [
            Tab(
              icon: Icon(Icons.phone, color: Color.fromRGBO(209, 77, 90, 1)),
              text: 'Phone Validated',
            ),
            Tab(
              icon: Icon(Icons.map, color: Color.fromRGBO(209, 77, 90, 1)),
              text: 'Field Validated',
            ),
          ],
          labelColor: Color.fromRGBO(209, 77, 90, 1),
          unselectedLabelColor: const Color.fromARGB(207, 135, 135, 135),
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
                    final historiques = historique[index];
                    final solvedAt = historiques['solving_time'] != null
                        ? formatDate(historiques['solving_time'])
                        : 'Unknown date';
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.task,
                          color: Color.fromRGBO(209, 77, 90, 1),
                        ),
                        title:
                            Text('Numéro Ticket: ${historiques['reference']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type Ticket: ${historiques['type']}'),
                            Text('Date cloture: $solvedAt'),
                          ],
                        ),
                        onTap: () {
                          // Naviguer vers l'écran TicketDetails
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketDetailScreenTech(
                                ticket: historiques,
                                ticketId: '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
