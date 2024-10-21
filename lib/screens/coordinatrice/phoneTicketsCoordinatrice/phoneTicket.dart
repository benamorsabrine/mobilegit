import 'package:flutter/material.dart';
import 'package:todo/screens/tickets/phoneAssigned.dart';
import 'package:todo/screens/tickets/phoneaccepted.dart';
import 'package:todo/screens/tickets/phoneapprouved.dart';
import 'package:todo/screens/tickets/phoneloading.dart';
import 'package:todo/screens/tickets/phonereported.dart';
import 'package:todo/screens/tickets/phonesolved.dart';
import 'package:todo/screens/config/config_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PTicketScreen extends StatefulWidget {
  final String token;
  final String? email;
  final String? id;

  const PTicketScreen({super.key, required this.token, this.email, this.id});

  @override
  _PTicketScreenScreenState createState() => _PTicketScreenScreenState();
}

class _PTicketScreenScreenState extends State<PTicketScreen> {
  bool isLoading = false;
  int assignedCount = 0;
  int approuvedCount = 0;
  int acceptedCount = 0;
  int loadingCount = 0;
  int solvedCount = 0;
  int reportedCount = 0;
  @override
  void initState() {
    super.initState();
    fetchTicketCounts(); // Appel initial pour récupérer les compteurs
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> fetchTicketCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/countphone/${widget.id}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          print(responseData);
          setState(() {
            assignedCount = responseData['assigned'] ?? 0;
            approuvedCount = responseData['approuved'] ?? 0;
            acceptedCount = responseData['accepted'] ?? 0;
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
    await fetchTicketCounts();
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
                                builder: (context) => PhoneAssignedScreen(
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
                          'Accepted Tickets',
                          acceptedCount,
                          const Color(0xFFE59BE9),
                          Icons.done,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneAcceptedScreen(
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
                          'Loading Tickets',
                          loadingCount,
                          Colors.orange,
                          Icons.hourglass_empty,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneLoadingScreen(
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
                          'Solved Tickets',
                          solvedCount,
                          Colors.green,
                          Icons.check_circle_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneSolvedScreen(
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
                          'Reported Tickets',
                          reportedCount,
                          Colors.grey,
                          Icons.report_problem,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneReportedScreen(
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
                          'Approuved Tickets',
                          approuvedCount,
                          const Color(0xFF80C4E9),
                          Icons.check_circle,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneApprouvedScreen(
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
