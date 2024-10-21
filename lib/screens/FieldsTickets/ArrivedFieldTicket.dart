import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/FieldsTickets/LoadingFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/ReportedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/qrCodeScreen.dart';
import 'package:todo/screens/FieldsTickets/qrCodeScreenFin.dart';
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:todo/screens/tickets/ticketDetails.dart';
import 'package:todo/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class FieldArrivedScreen extends StatefulWidget {
  final String token;
  final String? email;

  const FieldArrivedScreen({super.key, required this.token, this.email});

  @override
  _FieldArrivedScreenState createState() => _FieldArrivedScreenState();
}

class _FieldArrivedScreenState extends State<FieldArrivedScreen> {
  final ConfigService configService = ConfigService();
  bool isLoading = false;
  List<dynamic> tickets = [];
  String lat = '';
  String long = '';
  String locationMessage = 'Current location of the User';
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
          setState(() {
            tickets = responseData
                .where((ticket) => ticket['status'] == 'ARRIVED')
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

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Location permissions are denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Location permissions are permanently denied
    }

    return true; // Location permissions are granted
  }

  Future<void> checkAndRequestPermissions() async {
    final status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }
  }

// Ajoutez une variable pour suivre les tentatives
  int attemptCount = 0;

  void showErrorDialog(BuildContext context,
      {String message = "Veuillez réessayer plus tard"}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur"),
          content: Text(message),
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

  Future<void> handleStartTicket(BuildContext context, String ticketId) async {
    bool hasLocationPermission = await checkLocationPermission();

    if (!hasLocationPermission) {
      showErrorDialog(
        context,
        message:
            "Localisation non autorisée. Veuillez l'autoriser dans les paramètres.",
      );
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final response = await http.get(
      Uri.parse('$address:$port/api/ticket/$ticketId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final ticketData = json.decode(response.body);
      final double? equipmentLat = ticketData['equipement']['latitude'];
      final double? equipmentLong = ticketData['equipement']['longitude'];
      final String? numeroSerie = ticketData['equipement']['numero_serie'];

      // Affiche la position de l'équipement dans les logs
      print(
          "Position de l'équipement : Latitude: $equipmentLat , Longitude: $equipmentLong");
      print("Numéro de série de l'équipement: $numeroSerie");

      // Affiche la position de l'utilisateur
      print(
          "Votre position : Latitude: ${currentPosition.latitude} , Longitude: ${currentPosition.longitude}");

      // Vérification de la position de l'équipement
      if (equipmentLat == null ||
          equipmentLong == null ||
          equipmentLat == 0.0 ||
          equipmentLong == 0.0) {
        showErrorDialogCoord(
          context,
          message:
              "L'équipement ne possède pas de position, veuillez contacter la coordinatrice.",
        );
        return; // Arrête l'exécution ici pour éviter une autre alerte
      }

      // Calcul de la distance
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        equipmentLat,
        equipmentLong,
      );

      if (distance > 20.0) {
        attemptCount++;
        print(
            "Votre position est loin : Latitude: ${currentPosition.latitude} , Longitude: ${currentPosition.longitude}");

        if (attemptCount >= 4) {
          showErrorDialogCoord(
            context,
            message: "Veuillez appeler la coordinatrice.",
          );
          attemptCount = 0;
          return;
        } else {
          showErrorDialogPosition(
            context,
            message: "Vous n'êtes pas sur le bon site",
          );
          return;
        }
      } else {
        distance = 0.0; // Considérer comme même localisation

        // Ouvrir le scanner QR code
        final qrCodeResult = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
        );

        if (qrCodeResult != null && numeroSerie != null) {
          // Passez le résultat (code QR scanné) à la fonction `updateTicketStatus`
          await updateTicketStatus(
              context, ticketId, qrCodeResult, numeroSerie);
        }
      }
    } else {
      showErrorDialog(context, message: "Numéro de série manquant.");
    }
  }

// Normalisation du numéro de série
  String normalizeSerialNumber(String serial) {
    return serial.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

// Comparaison partielle
  bool compareSerialNumbers(String scannedCode, String equipmentSerial) {
    String normalizedScannedCode = normalizeSerialNumber(scannedCode);
    String normalizedEquipmentSerial = normalizeSerialNumber(equipmentSerial);

    // Vérifie si le code scanné contient le numéro de série de l'équipement
    return normalizedScannedCode.contains(normalizedEquipmentSerial);
  }

  Future<void> updateTicketStatus(BuildContext context, String ticketId,
      String qrResult, String? numeroSerie) async {
    try {
      print("updateticket function is called");
      //    print("equipement num serie : ${equipement.numero_serie}");
      // Vérifier si le numero_serie est bien récupéré avant la comparaison
      if (numeroSerie == null) {
        showErrorDialog(context,
            message: "Le numéro de série de l'équipement est manquant.");
        return;
      }

      // Comparaison des codes QR
      if (!compareSerialNumbers(qrResult, numeroSerie)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Code QR incorrect'),
              content: const Text(
                  'Le code QR scanné ne correspond pas à l\'équipement.'),
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
        return;
      }

      // Proceed with updating ticket if the comparison is successful
      final updateResponse = await http.put(
        Uri.parse('$address:$port/api/ticket/startedScan/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}'
        },
        body: json.encode({
          'status': 'HANDLED',
          'codeqrStart': qrResult,
          'starting_time': DateTime.now().toIso8601String(),
        }),
      );

      if (updateResponse.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ticket commencé avec succès!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FieldLoadingScreen(token: widget.token),
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
        showErrorDialog(context,
            message: "Erreur lors de la mise à jour du statut du ticket.");
      }
    } catch (error) {
      showErrorDialog(context,
          message: "Une erreur s'est produite lors de la mise à jour.");
    }
  }

  void showErrorDialogCoord(BuildContext context, {required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.phone, color: Colors.red), // Icône de téléphone
              SizedBox(width: 8), // Espacement entre l'icône et le texte
              Text(
                'Alerte',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, color: Colors.red), // Icône d'erreur
              const SizedBox(width: 8), // Espacement entre l'icône et le texte
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                //    FlutterPhoneDirectCall.callNumber('+20202020') ;
                // launchUrl('tel:+52268475' as Uri);
                FlutterPhoneDirectCaller.callNumber('+20202020');
              },
              child: const Row(
                children: [
                  Icon(Icons.phone, color: Colors.blue), // Icône de téléphone
                  SizedBox(width: 4), // Espacement entre l'icône et le texte
                  Text('Appeler', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialogPosition(BuildContext context,
      {required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wrong_location,
                  color: Colors.red), // Icône de téléphone
              SizedBox(width: 8), // Espacement entre l'icône et le texte
              Text(
                'Alerte',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, color: Colors.red), // Icône d'erreur
              const SizedBox(width: 8), // Espacement entre l'icône et le texte
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
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

  Future<String> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Utils.showToast("Location services are disabled. Opening settings...");
      await Geolocator.openLocationSettings();
      return "Location services are disabled. Click on start again";
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Utils.showToast("Location permissions are denied.");
        return "Location permissions are denied.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Utils.showToast("Location permissions are permanently denied.");
      return "Location permissions are permanently denied.";
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String lat = '${position.latitude}';
      String long = '${position.longitude}';
      return 'Latitude: $lat, Longitude: $long';
    } catch (e) {
      Utils.showToast("Failed to get location: $e");
      return "Failed to get location.";
    }
  }

  Future<void> handleReportTicket(String ticketId) async {
    String reportingNoteArrived =
        ''; // Variable pour stocker la raison du report

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reporting Ticket ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Pourquoi voulez-vous reporter le ticket ?'),
              TextField(
                onChanged: (value) {
                  reportingNoteArrived =
                      value; // Met à jour la raison du report à chaque changement
                },
                decoration: const InputDecoration(
                  hintText: 'Raison du report',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Annule l'action de report
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (reportingNoteArrived.trim().isEmpty) {
                  // Affiche un message d'erreur si le champ est vide
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Attention'),
                        content: const Text(
                            'Le champ de raison du report est requis.'),
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
                  return; // Arrête l'exécution si le champ est vide
                }
                Navigator.of(context).pop(true); // Confirme l'action de report
                try {
                  final response = await http.put(
                    Uri.parse(
                        '$address:$port/api/ticket/ReportingArrivedField/$ticketId'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'status': 'REPORTED',
                      'reporting_note_arrived': reportingNoteArrived,
                      'reporting_arrivedTicket_time':
                          DateTime.now().toIso8601String(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Reporté avec succès!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FieldReportedScreen(
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
                    throw Exception('Échec du report du ticket');
                  }
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Erreur lors du report"),
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
              },
              child: const Text('Reporter'),
            ),
          ],
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text(
  //         'Arrived',
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
  //                   'No arrived tickets found.',
  //                   style: TextStyle(fontSize: 20),
  //                 ),
  //               )
  //             : ListView.builder(
  //                 itemCount: tickets.length,
  //                 itemBuilder: (context, index) {
  //                   return Card(
  //                     margin: const EdgeInsets.all(10),
  //                     color: const Color.fromRGBO(231, 236, 250, 1),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(15),
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(10.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           ListTile(
  //                             leading: Icon(
  //                               Icons.info,
  //                               color: Color.fromRGBO(209, 77, 90, 1),
  //                             ),
  //                             title: Text(
  //                               tickets[index]['reference'] ?? 'N/A',
  //                               style: const TextStyle(
  //                                 fontWeight: FontWeight.w600,
  //                                 fontSize: 18,
  //                                 color: Color.fromRGBO(50, 50, 50, 1),
  //                               ),
  //                             ),
  //                             onTap: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       TicketDetailScreenTech(
  //                                     ticketId: tickets[index]['_id'],
  //                                     ticket: null,
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                             subtitle: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     const Text(
  //                                       "Status: ",
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.w600,
  //                                         fontSize: 14,
  //                                         color: Color.fromRGBO(52, 52, 52, 1),
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       tickets[index]['status'] ?? 'N/A',
  //                                       style: const TextStyle(
  //                                         fontSize: 14,
  //                                         color: Color.fromARGB(
  //                                             255, 102, 102, 102),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           const SizedBox(height: 10),
  //                           Row(
  //                             children: [
  //                               Expanded(
  //                                 child: ElevatedButton(
  //                                   onPressed: () {
  //                                     handleStartTicket(
  //                                         context, tickets[index]['_id']);
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: const Color.fromARGB(
  //                                         255, 10, 196, 81),
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                     ),
  //                                   ),
  //                                   child: const Text(
  //                                     'Start',
  //                                     style: TextStyle(color: Colors.white),
  //                                   ),
  //                                 ),
  //                               ),
  //                               const SizedBox(
  //                                   width: 10), // Add spacing between buttons
  //                               Expanded(
  //                                 child: ElevatedButton(
  //                                   onPressed: () {
  //                                     handleReportTicket(tickets[index]['_id']);
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: const Color.fromARGB(
  //                                         255, 126, 126, 126),
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                     ),
  //                                   ),
  //                                   child: const Text(
  //                                     'Report',
  //                                     style: TextStyle(color: Colors.white),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
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
          'Arrived',
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
                    'No arrived tickets found.',
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
    print('Help desk : ${ticket['technicien_transfer']}');
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
          "Help Desk: ",
          ticket['technicien'] is Map
              ? "${ticket['technicien']['firstname']} ${ticket['technicien']['lastname']}"
              : 'Non spécifié',
        ),
      ],
    );
  }

  Widget _buildDateAndNote(Map<String, dynamic> ticket) {
    print('Date de transfert: ${ticket['transfering_time']}');
    return Column(
      children: [
        _buildRow("Note: ", ticket['note'] ?? 'N/A'),
        // _buildRow(
        //     "Date de transfert: ", formatDate(ticket['transfering_time'])),
        // _buildRow(
        //     "Heure de transfert : ", formatTime(ticket['transfering_time'])),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 30),
          ElevatedButton.icon(
            onPressed: () {
              handleReportTicket(ticket[
                  '_id']); // Utiliser le paramètre 'ticket' correctement ici
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 122, 122, 122),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            icon: const Icon(Icons.report, color: Colors.white),
            label: const Text(
              'Report',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 25),
          ElevatedButton.icon(
            onPressed: () {
              handleStartTicket(context, ticket['_id']); // Corriger ici aussi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 240, 174, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text(
              'Start',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
