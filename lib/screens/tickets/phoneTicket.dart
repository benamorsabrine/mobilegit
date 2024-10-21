import 'package:flutter/material.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/screens/tickets/phoneAssigned.dart';
import 'package:todo/screens/tickets/phoneaccepted.dart';
import 'package:todo/screens/tickets/phoneapprouved.dart';
import 'package:todo/screens/tickets/phoneloading.dart';
import 'package:todo/screens/tickets/phonereported.dart';
import 'package:todo/screens/tickets/phonesolved.dart';
import 'package:todo/screens/config/config_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todo/screens/tickets/phonetransfered.dart';

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
  int handledCount = 0;
  int validatedCount = 0;
  int reportedCount = 0;
  int tobetransfered = 0;
  int completedCount = 0;
  int phoneTicketCount = 0;
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
            handledCount = responseData['handled'] ?? 0;
            validatedCount = responseData['validated'] ?? 0;
            reportedCount = responseData['reported'] ?? 0;
            tobetransfered = responseData['tobetransfered'] ?? 0;
            completedCount = responseData['completed'] ?? 0;
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

  Future<void> countPhoneTicket() async {
    print("Widget ID: ${widget.id}");
    print("function count total phone is called ON PHONE TCIKET SCREEN");

    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/counttotalphone/${widget.id}'),
      );

      if (response.statusCode == 200) {
        print(
            "Response body: ${response.body}"); // Affiche le corps de la réponse
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Vérifiez que 'totalCount' existe avant de l'utiliser
        if (jsonResponse.containsKey('totalCount dans phoneticket screen')) {
          setState(() {
            phoneTicketCount =
                jsonResponse['totalCount']; // Met à jour le nombre de tickets
          });
        } else {
          print("Clé 'totalCount' non trouvée dans la réponse");
          setState(() {
            phoneTicketCount = 0; // En cas d'erreur
          });
        }
      } else {
        print('Erreur: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        phoneTicketCount = 0; // En cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await countPhoneTicket(); // Appelle la fonction avant de revenir
        return true; // Autorise la navigation
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Icône du bouton de retour
            onPressed: () async {
              await countPhoneTicket(); // Appelle la fonction avant de revenir
              Navigator.pop(context); // Retourne à l'écran précédent
            },
          ),
          title: const Text(
            'Process Phone Tickets',
            style:
                TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 20),
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
                        height:
                            50), // espace entre l'AppBar et la première ligne
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: buildTicketCard(
                            'Assigned ',
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
                            'Accepted ',
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
                            'Handled ',
                            handledCount,
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
                            'Completed ',
                            completedCount,
                            const Color.fromARGB(255, 40, 176, 217),
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
                            'Transfered to field',
                            tobetransfered,
                            const Color.fromARGB(255, 224, 60, 219),
                            Icons.send,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhoneTransferedScreen(
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
                            'Validated ',
                            validatedCount,
                            const Color.fromARGB(255, 68, 178, 32),
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
                    const SizedBox(height: 20),
                    // Row for the "Reported Tickets" card
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align to the left
                      children: [
                        Container(
                          width: 175, // Specify the width
                          height: 120, // Specify the height
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: buildTicketCard(
                            'Reported ',
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
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildTicketCard(String title, int count, Color color, IconData icon,
      VoidCallback onPressed) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Suppression du padding pour minimiser l'espace à gauche
                Container(
                  width: 30, // Ajustez si nécessaire
                  alignment: Alignment.center, // Aligne à gauche
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 5), // Small space between icon and text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align text to left
                    children: [
                      for (String word in title.split(" "))
                        Text(
                          word,
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
