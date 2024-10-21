import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:todo/screens/auth/login_screen.dart';
import 'package:todo/screens/coordinatrice/FieldsTicketsCoordinatrice/FieldTickets.dart';
import 'package:todo/screens/coordinatrice/phoneTicketsCoordinatrice/phoneTicket.dart';
import 'package:todo/screens/coordinatrice/alerteCoordinatrice.dart';
import 'package:todo/screens/coordinatrice/clientManagement.dart';
import 'package:todo/screens/coordinatrice/historique.dart';

import 'package:todo/screens/pages/equipement.dart';
import 'package:todo/screens/pages/notification.dart';
import 'package:todo/screens/pages/profile.dart';

class HomeCordinatrice extends StatefulWidget {
  final String token;
  final String email;

  const HomeCordinatrice({super.key, required this.token, required this.email});

  @override
  State<HomeCordinatrice> createState() => _HomeCordinatriceScreenState();
}

class _HomeCordinatriceScreenState extends State<HomeCordinatrice> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedDrawerIndex = 0;
  int _selectedIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            builder: (context) => const NotificationScreen(token: '',),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldTicketScreen(
              token: widget.token,
              id: '', // Ensure id is passed or handled
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PTicketScreen(
              token: widget.token,
              id: '', // Pass an id or appropriate value
            ),
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
              id: '',
            ),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldTicketScreen(
              token: widget.token,
              id: '', // Ensure id is passed or handled
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EquipementScreen(),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.token);
    print(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Coordinatrice',
          style: TextStyle(
            color: Color.fromRGBO(209, 77, 90, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       // First part: Header
      //       DrawerHeader(
      //         decoration: const BoxDecoration(
      //           color: Color.fromRGBO(
      //               231, 236, 250, 1), // Keep header color unchanged
      //         ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             CircleAvatar(
      //               radius: 30,
      //               backgroundColor: Color.fromRGBO(209, 77, 90, 1),
      //               backgroundImage: const AssetImage('assets/avatar.png'),
      //               child: const Icon(
      //                 Icons.person,
      //                 size: 30,
      //                 color: Colors.white,
      //               ),
      //             ),
      //             const SizedBox(height: 10),
      //             const Text(
      //               'Welcome User',
      //               style: TextStyle(
      //                 color: Color.fromRGBO(209, 77, 90, 1),
      //                 fontSize: 18,
      //               ),
      //             ),
      //             const SizedBox(height: 5),
      //             Text(
      //               widget.email,
      //               style: const TextStyle(
      //                 color: Color.fromRGBO(209, 77, 90, 1),
      //                 fontSize: 14,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),

      //       // Second part: List of options
      //       Container(
      //         //   color: const Color.fromARGB(255, 254, 254,
      //         //       254), // Set background color of the second part to black
      //         child: Column(
      //           children: [
      //             ListTile(
      //               tileColor: _selectedDrawerIndex == 0
      //                   ? const Color.fromRGBO(231, 236, 250, 1)
      //                   : null,
      //               leading: const Icon(
      //                 Icons.phone_android,
      //                 color: Color.fromRGBO(209, 77, 90, 1),
      //               ),
      //               title: const Text(
      //                 'Phone Tickets',
      //                 style: TextStyle(
      //                     color: Color.fromRGBO(
      //                         209, 77, 90, 1)), // Set text color to white
      //               ),
      //               onTap: () => _onDrawerItemTapped(0),
      //             ),
      //             ListTile(
      //               tileColor: _selectedDrawerIndex == 1
      //                   ? const Color.fromRGBO(231, 236, 250, 1)
      //                   : null,
      //               leading: const Icon(
      //                 Icons.assignment,
      //                 color: Color.fromRGBO(209, 77, 90, 1),
      //               ),
      //               title: const Text(
      //                 'Field Tickets',
      //                 style: TextStyle(
      //                     color: Color.fromRGBO(
      //                         175, 175, 175, 1)), // Set text color to white
      //               ),
      //               onTap: () => _onDrawerItemTapped(1),
      //             ),
      //             ListTile(
      //               tileColor: _selectedDrawerIndex == 2
      //                   ? const Color.fromRGBO(231, 236, 250, 1)
      //                   : null,
      //               leading: const Icon(
      //                 Icons.storage_outlined,
      //                 color: Color.fromRGBO(209, 77, 90, 1),
      //               ),
      //               title: const Text(
      //                 'Equipements',
      //                 style: TextStyle(
      //                     color: Color.fromRGBO(
      //                         175, 175, 175, 1)), // Set text color to white
      //               ),
      //               onTap: () => _onDrawerItemTapped(2),
      //             ),
      //             const Divider(
      //                 color: Colors.white), // Optional: make divider white
      //             ListTile(
      //               tileColor: _selectedDrawerIndex == 3
      //                   ? const Color.fromRGBO(231, 236, 250, 1)
      //                   : null,
      //               leading: const Icon(
      //                 Icons.logout,
      //                 color: Color.fromRGBO(209, 77, 90, 1),
      //               ),
      //               title: const Text(
      //                 'Logout',
      //                 style: TextStyle(
      //                     color: Color.fromRGBO(
      //                         175, 175, 175, 1)), // Set text color to white
      //               ),
      //               onTap: () async {
      //                 SharedPreferences prefs =
      //                     await SharedPreferences.getInstance();
      //                 await prefs.remove('token');
      //                 _onDrawerItemTapped(3); // Logout and redirect
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
            ListTile(
              leading: const Icon(Icons.settings,
                  color: Color.fromRGBO(209, 77, 90, 1)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(
                    context, '/settings'); // Navigate to settings
              },
            ),

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
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PTicketScreen(
                          token: widget.token, id: '',
                          //email: email,
                        ),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone,
                        color: Color.fromRGBO(209, 77, 90, 1), size: 40),
                    SizedBox(height: 15),
                    Text(
                      'Phone Tickets',
                      style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1)),
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
                      builder: (context) => FieldTicketScreen(
                        token: widget.token,
                        id: '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map,
                        color: Color.fromRGBO(209, 77, 90, 1), size: 40),
                    SizedBox(height: 15),
                    Text(
                      'Fields Tickets',
                      style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1)),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Clientmanagement(
                          token: widget.token, email: widget.email),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people,
                        color: Color.fromRGBO(209, 77, 90, 1), size: 40),
                    SizedBox(height: 15),
                    Text(
                      'Clients',
                      style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1)),
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
                  backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pages,
                        color: Color.fromRGBO(209, 77, 90, 1), size: 40),
                    SizedBox(height: 15),
                    Text(
                      'Historique',
                      style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1)),
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
                  backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning,
                        color: Color.fromRGBO(209, 77, 90, 1), size: 40),
                    SizedBox(height: 15),
                    Text(
                      'Warnings',
                      style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1)),
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
                          email: widget.email,
                        ),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
                  minimumSize: const Size(140, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromRGBO(209, 77, 90, 1),
                      width: 1,
                    ), // Bordure
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person,
                        color: Color.fromRGBO(209, 77, 90, 1), size: 40),
                    SizedBox(height: 15),
                    Text(
                      'Profile',
                      style: TextStyle(
                          color: Color.fromRGBO(209, 77, 90, 1)), // text color
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color:
            const Color.fromARGB(255, 18, 17, 17), // Couleur de fond souhaitée
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Field Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone),
              label: 'Phone Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromRGBO(209, 77, 90, 1),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
