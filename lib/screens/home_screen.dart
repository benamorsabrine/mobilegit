import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:todo/screens/FieldsTickets/FieldTickets.dart';
import 'package:todo/screens/auth/login_screen.dart';
import 'package:todo/screens/config/config_service.dart';
import 'package:todo/screens/pages/alerte.dart';
import 'package:todo/screens/pages/equipement.dart';
import 'package:todo/screens/pages/historique.dart';
import 'package:todo/screens/pages/notification.dart';
import 'package:todo/screens/pages/profile.dart';
import 'package:todo/screens/tickets/phoneTicket.dart';
import 'package:http/http.dart' as http;
import 'package:todo/api/firebase_api.dart' ;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class HomeScreen extends StatefulWidget {
  final String token;
  final String id;
  final String email;

  const HomeScreen(
      {super.key, required this.token, required this.email, required this.id});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigService configService = ConfigService();
  late final String userId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedDrawerIndex = 0; // Variable d'état pour le Drawer
  int _selectedIndex = 0;
  int phoneTicketCount = 0;
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("HomeScreen initState called");
    countPhoneTicket();
    print(widget.token);
    print(widget.email);
    print(widget.id);

    _loadConfiguration();
     NotificationService.initPushNotification(); 
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showNotification(message);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    countPhoneTicket(); // Appelle la fonction pour mettre à jour le compteur
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    countPhoneTicket(); // Appelle la fonction lorsque le widget change de dépendances
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  Future<void> countPhoneTicket() async {
    var address = ConfigService().adresse;
    var port = ConfigService().port;
    print("Widget ID dans homescreen: ${widget.id}");
    print("function count total phone is called on home screen");

    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/ticket/counttotalphone/${widget.id}'),
      );

      if (response.statusCode == 200) {
        print(
            "Response body: ${response.body}"); // Affiche le corps de la réponse
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Vérifiez que 'totalCount' existe avant de l'utiliser
        if (jsonResponse.containsKey('totalCount')) {
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

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen(token: widget.token),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FieldTicketScreen(token: widget.token, id: widget.id),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PTicketScreen(token: widget.token, id: widget.id),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              token: widget.token,
              email: widget.email,
            ),
          ),
        );
        break;
    }
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PTicketScreen(
              token: widget.token,
            ),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FieldTicketScreen(token: widget.token, id: widget.id)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Received token in HomeScreen: ${widget.token}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',
            style: TextStyle(
              color: Color.fromRGBO(209, 77, 90, 1),
            )),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: countPhoneTicket,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer Header with User Info
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(231, 236, 250, 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color.fromRGBO(
                        209, 77, 90, 1), // Couleur de fond pour l'avatar
                    child: Icon(
                      Icons.person, // Icône de l'utilisateur
                      size: 40,
                      color: Colors.white, // Couleur de l'icône
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome, User',
                    style: TextStyle(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      color: Color.fromRGBO(225, 108, 119, 1),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Color.fromRGBO(209, 77, 90, 1),
              ),
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Color.fromRGBO(56, 56, 56, 1), // Couleur du texte
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.pushNamed(
                    context, '/home'); // Navigation vers l'écran home
              },
            ),

            ListTile(
              leading: const Icon(Icons.person,
                  color: Color.fromRGBO(209, 77, 90, 1)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/profile'); // Navigate to profile
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.settings,
            //       color: Color.fromRGBO(209, 77, 90, 1)),
            //   title: const Text('Settings'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     Navigator.pushNamed(
            //         context, '/settings'); // Navigate to settings
            //   },
            // ),

            // Divider between items

            // Logout Button
            Divider(),

            ListTile(
              leading: const Icon(Icons.logout,
                  color: Color.fromRGBO(209, 77, 90, 1)),
              title: const Text('Logout'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            )
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PTicketScreen(token: widget.token, id: widget.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(231, 236, 250, 1), // Couleur de fond
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                  elevation: 5, // Ombre
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      color: Color.fromRGBO(209, 77, 90, 1),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Phone ticket',
                      style: TextStyle(
                        color:
                            Color.fromRGBO(209, 77, 90, 1), // Couleur du texte
                      ),
                    ),
                    if (phoneTicketCount >
                        0) // Affiche uniquement si le nombre est > 0
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$phoneTicketCount', // Affiche le nombre de tickets
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FieldTicketScreen(token: widget.token, id: widget.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(231, 236, 250, 1), // Couleur de fond
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                  elevation: 5, // Ombre
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      color: Color.fromRGBO(209, 77, 90, 1),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'FieldTicket',
                      style: TextStyle(
                        color:
                            Color.fromRGBO(209, 77, 90, 1), // Couleur du texte
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EquipementScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(231, 236, 250, 1), // Couleur de fond
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                  elevation: 5, // Ombre
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      color: Color.fromRGBO(209, 77, 90, 1),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Equipement',
                      style: TextStyle(
                        color:
                            Color.fromRGBO(209, 77, 90, 1), // Couleur du texte
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoriqueScreen(token: widget.token),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(231, 236, 250, 1), // Couleur de fond
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                  elevation: 5, // Ombre
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Color.fromRGBO(209, 77, 90, 1),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Historique',
                      style: TextStyle(
                        color:
                            Color.fromRGBO(209, 77, 90, 1), // Couleur du texte
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlerteScreen(token: widget.token),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(231, 236, 250, 1), // Couleur de fond
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                  elevation: 5, // Ombre
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Color.fromRGBO(209, 77, 90, 1),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Alertes',
                      style: TextStyle(
                        color:
                            Color.fromRGBO(209, 77, 90, 1), // Couleur du texte
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        token: widget.token,
                        email: '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(231, 236, 250, 1), // Couleur de fond
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(225, 123, 133, 1),
                      width: 1,
                    ), // Bordure
                  ),
                  elevation: 5, // Ombre
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: Color.fromRGBO(209, 77, 90, 1),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color:
                            Color.fromRGBO(209, 77, 90, 1), // Couleur du texte
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Espacement égal entre les boutons
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.notifications),
              color: _selectedIndex == 0
                  ? Color.fromRGBO(209, 77, 90, 1)
                  : Colors.grey,
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            IconButton(
              icon: Icon(Icons.phone),
              color: _selectedIndex == 2
                  ? Color.fromRGBO(209, 77, 90, 1)
                  : Colors.grey,
              onPressed: () {
                _onItemTapped(2);
              },
            ),
            IconButton(
              icon: Icon(Icons.map),
              color: _selectedIndex == 1
                  ? Color.fromRGBO(209, 77, 90, 1)
                  : Colors.grey,
              onPressed: () {
                _onItemTapped(1);
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              color: _selectedIndex == 3
                  ? Color.fromRGBO(209, 77, 90, 1)
                  : Colors.grey,
              onPressed: () {
                _onItemTapped(3);
              },
            ),
          ],
        ),
        color: Color.fromRGBO(231, 236, 250, 1), // Couleur de fond rouge
      ),
    );
  }
}
