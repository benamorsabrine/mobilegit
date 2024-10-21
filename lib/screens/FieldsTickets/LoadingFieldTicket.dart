import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo/screens/FieldsTickets/ReportedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/solvingTicketModalField.dart';
import 'package:todo/screens/tickets/ticketDetails.dart';
import 'package:todo/screens/config/config_service.dart';
import 'package:todo/utils/toast.dart';

class FieldLoadingScreen extends StatefulWidget {
  final String token;
  final String? email;

  const FieldLoadingScreen({super.key, required this.token, this.email});

  @override
  _FieldLoadingScreenState createState() => _FieldLoadingScreenState();
}

class _FieldLoadingScreenState extends State<FieldLoadingScreen> {
  final ConfigService configService = ConfigService();
  String imageBase64 = '';
  bool isImageUploaded = false;
  String imageError = '';
  bool isLoading = false;
  String lat = '';
  String long = '';
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

  int attemptCount = 0;
  Future<void> fetchAssignedTickets() async {
    setState(() {
      isLoading = true;
    });
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
                .where((ticket) => ticket['status'] == 'HANDLED')
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to handled tickets: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching alerts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<double> calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
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

// Fonction pour vérifier la distance avant d'afficher le dialogue
  Future<void> handleStart(BuildContext context, String ticketId, String token,
      double ticketLatitude, double ticketLongitude) async {
    bool hasLocationPermission = await checkLocationPermission();

    if (!hasLocationPermission) {
      print('Location permission denied');
      return;
    }

    // Demande la position actuelle de l'utilisateur
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Affiche la position actuelle dans la console
    print(
        'Position actuelle : Latitude: ${position.latitude}, Longitude: ${position.longitude}');

    // Affiche la position extraite du ticket dans la console
    print(
        'Position du ticket : Latitude: $ticketLatitude, Longitude: $ticketLongitude');

    // Calcule la distance entre la position actuelle et celle du ticket
    double distance = await calculateDistance(
      position.latitude,
      position.longitude,
      ticketLatitude,
      ticketLongitude,
    );

    if (distance < 20) {
      // Si la distance est inférieure à 20 mètres, afficher le dialogue
      showSimpleHelloDialog(
          context, ticketId, token, ticketLatitude, ticketLongitude);
    } else {
      // Sinon, afficher un message d'erreur
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur de localisation'),
            content: Text(
                'Vous n\'êtes pas au bon site. Veuillez vérifier votre position.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // Continuer normalement sans la vérification de position
    // showSimpleHelloDialog(
    //     context, ticketId, token, ticketLatitude, ticketLongitude);
  }

  void showSimpleHelloDialog(BuildContext context, String ticketId,
      String token, double ticketLatitude, double ticketLongitude) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleHelloDialogField(
          ticketId: ticketId,
          token: token,
          ticketLatitude: ticketLatitude, // Passez la latitude ici
          ticketLongitude: ticketLongitude, // Passez la longitude ici
        );
      },
    );
  }

  // void showSimpleHelloDialog(
  //     BuildContext context, String ticketId, String token) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SimpleHelloDialogField(ticketId: ticketId, token: token);
  //     },
  //   );
  // }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text(
  //         'Handled Tickets',
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
  //                   'No loading tickets found.',
  //                   style: TextStyle(fontSize: 20),
  //                 ),
  //               )
  //             : ListView.builder(
  //                 itemCount: tickets.length,
  //                 itemBuilder: (context, index) {
  //                   return Card(
  //                     margin: const EdgeInsets.all(10),
  //                     color: const Color.fromRGBO(
  //                         231, 236, 250, 1), // Couleur de fond de la carte
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(
  //                           15), // Arrondi des bords de la carte
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           ListTile(
  //                             title: Text(
  //                               tickets[index]['reference'] ?? 'N/A',
  //                               style: const TextStyle(
  //                                 fontWeight:
  //                                     FontWeight.w600, // Poids de la police
  //                                 fontSize: 18, // Taille de la police
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
  //                                         fontWeight: FontWeight
  //                                             .bold, // Poids de la police
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       tickets[index]['status'] ?? 'N/A',
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           const SizedBox(
  //                               height:
  //                                   10), // Add spacing between text and buttons
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Expanded(
  //                                 child: ElevatedButton(
  //                                   onPressed: () {
  //                                     String ticketId = tickets[index]['_id'];
  //                                     String token = widget.token;

  //                                     // Récupérer les coordonnées de l'équipement
  //                                     var equipement =
  //                                         tickets[index]['equipement'];
  //                                     double ticketLatitude =
  //                                         equipement['latitude'] ?? 0.0;
  //                                     double ticketLongitude =
  //                                         equipement['longitude'] ?? 0.0;

  //                                     // Appeler la fonction handleStart
  //                                     handleStart(context, ticketId, token,
  //                                         ticketLatitude, ticketLongitude);
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: const Color.fromARGB(
  //                                         255, 10, 196, 81),
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                     ),
  //                                   ),
  //                                   child: const Text(
  //                                     'Solved',
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
  //                                     backgroundColor: const Color.fromARGB(255,
  //                                         126, 126, 126), // Couleur du bouton
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(
  //                                           10), // Bouton avec coins arrondis
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
          'Handled Tickets',
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
                    'No loading tickets found.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: const Color.fromRGBO(
                          231, 236, 250, 1), // Couleur de fond de la carte
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            15), // Arrondi des bords de la carte
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                tickets[index]['reference'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600, // Poids de la police
                                  fontSize: 18, // Taille de la police
                                ),
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "Status: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Poids de la police
                                        ),
                                      ),
                                      Text(
                                        tickets[index]['status'] ?? 'N/A',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height:
                                    10), // Add spacing between text and buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      String ticketId = tickets[index]['_id'];
                                      String token = widget.token;

                                      // Vérifiez que l'équipement et les coordonnées ne sont pas null
                                      var equipement =
                                          tickets[index]['equipement'];
                                      if (equipement != null &&
                                          equipement['latitude'] != null &&
                                          equipement['longitude'] != null) {
                                        double ticketLatitude =
                                            equipement['latitude'];
                                        double ticketLongitude =
                                            equipement['longitude'];

                                        // Appeler la fonction handleStart si les coordonnées sont disponibles
                                        handleStart(context, ticketId, token,
                                            ticketLatitude, ticketLongitude);
                                      } else {
                                        // Affiche un message si les coordonnées sont manquantes
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Coordonnées manquantes'),
                                              content: Text(
                                                  'Les coordonnées GPS de l\'équipement ne sont pas disponibles.'),
                                              actions: [
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 10, 196, 81),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Solved',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    width: 10), // Add spacing between buttons
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      handleReportTicket(tickets[index]['_id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255,
                                          126, 126, 126), // Couleur du bouton
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Bouton avec coins arrondis
                                      ),
                                    ),
                                    child: const Text(
                                      'Report',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;

  Future<void> handleReportTicket(String ticketId) async {
    String reportingNoteSolve = '';
    String reportImg = ''; // Utilisation de l'image encodée

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reporting Ticket ?'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Pourquoi voulez-vous reporter le ticket ?'),
                  TextField(
                    onChanged: (value) {
                      reportingNoteSolve = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Raison du report',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isImageUploaded
                        ? null
                        : uploadImage, // Disable if image uploaded
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isImageUploaded
                          ? Colors.grey
                          : const Color.fromARGB(255, 176, 190, 173),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Upload Fiche Intervention',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  if (isImageUploaded)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Image uploaded successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  isImageUploaded =
                      false; // Réinitialisation du statut de l'image
                  imageBase64 = ''; // Réinitialisation du contenu de l'image
                });
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse(
                      '$address:$port/api/api/ticketht/assigned/field'), // wrong url
                  headers: {
                    'Authorization': 'Bearer ${widget.token}',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    'ticketId': ticketId,
                    'reporting_note_solve': reportingNoteSolve,
                    'report_img': reportImg,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      fetchAssignedTickets(); // Actualiser la liste des tickets
    }
  }

  Future<void> uploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final bytes = File(file.path!).readAsBytesSync();
        setState(() {
          imageBase64 = base64Encode(bytes);
          isImageUploaded = true;
        });
        print("image uplaoded succeffulyy ");
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}
