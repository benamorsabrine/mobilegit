import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/FieldsTickets/ApprouvedFieldTicket.dart';
import 'dart:convert';
import 'package:todo/screens/FieldsTickets/AssignedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/AcceptedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/EnRouteFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/ArrivedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/LoadingFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/SolvedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/ReportedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/TransferedFieldTicket.dart';
import 'package:todo/screens/config/config_service.dart';

class FieldTicketScreen extends StatefulWidget {
  final String token;
  final String? id;
  const FieldTicketScreen({super.key, required this.token, required this.id});

  @override
  _FieldTicketScreenState createState() => _FieldTicketScreenState();
}

class _FieldTicketScreenState extends State<FieldTicketScreen> {
  final ConfigService configService = ConfigService();
  bool isLoading = false;
  int assignedCount = 0;
  int transferedCount = 0;
  int approuvedCount = 0;
  int acceptedCount = 0;
  int enRouteCount = 0;
  int arrivedCount = 0;
  int loadingCount = 0;
  int solvedCount = 0;
  int reportedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    fetchTicketCounts(dynamic); // Appel initial pour récupérer les compteurs
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> fetchTicketCounts(dynamic configService) async {
    String address = configService.adresse;
    String port = configService.port;
    String? ticketId = widget.id;
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse('$address:$port/api/ticket/count/$ticketId');

    // try {
    //   final response = await http.get(
    //     // Uri.parse('$address:$port/api/ticket/count/${widget.id}'),
    //     Uri.parse('http://$address:$port/api/ticket/count/$ticketId'),
    //     headers: {
    //       'Authorization': 'Bearer ${widget.token}',
    //     },
    //   );
    // Vérification des valeurs
    if (address.isEmpty || port.isEmpty) {
      print('Erreur : Adresse ou port vide');
      return;
    }

    print('Final URL: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          print(responseData);
          setState(() {
            assignedCount = responseData['assigned'] ?? 0;
            transferedCount = responseData['transfered'] ?? 0;

            approuvedCount = responseData['approuved'] ?? 0;
            acceptedCount = responseData['accepted'] ?? 0;
            enRouteCount = responseData['enRoute'] ?? 0;
            arrivedCount = responseData['arrived'] ?? 0;
            loadingCount = responseData['loading'] ?? 0;
            solvedCount = responseData['solved'] ?? 0;
            reportedCount = responseData['reported'] ?? 0;
            isLoading = false;
          });
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to load ticket counts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching ticket counts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await fetchTicketCounts(dynamic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Process Tickets',
          style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(
                      height: 70), // espace entre l'AppBar et la première ligne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'Assigned Tickets',
                          assignedCount,
                          const Color(0xFFFF6868),
                          Icons.assignment,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldAssignedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'Transfered Tickets',
                          transferedCount,
                          const Color(0xFF80C4E9),
                          Icons.check_circle,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldTransferedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'Accepted Tickets',
                          acceptedCount,
                          const Color(0xFFFFB6B9),
                          Icons.directions,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldAcceptedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'En Route Tickets',
                          enRouteCount,
                          const Color(0xFF61C0BF),
                          Icons.location_on,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldEnRouteScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'Arrived Tickets',
                          arrivedCount,
                          const Color.fromARGB(255, 210, 176, 3),
                          Icons.hourglass_empty,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldArrivedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'Loading Tickets',
                          loadingCount,
                          Colors.orange,
                          Icons.check_circle_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldLoadingScreen(
                                  token: widget.token, 
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'Solved Tickets',
                          solvedCount,
                          Colors.green,
                          Icons.report_problem,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldSolvedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'Reported Tickets',
                          reportedCount,
                          Colors.grey,
                          Icons.check_circle_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldReportedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildTicketCard(String title, int count, Color color, IconData icon,
      VoidCallback onPressed) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                          height: 25), // Space to align text properly
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (count != 0)
            Positioned(
              top: -15,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
