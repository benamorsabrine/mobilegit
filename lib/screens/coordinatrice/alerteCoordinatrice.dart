import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/config/config_service.dart';

class AlerteScreen extends StatefulWidget {
  final String token;

  const AlerteScreen({super.key, required this.token});

  @override
  _AlerteScreenState createState() => _AlerteScreenState();
}

class _AlerteScreenState extends State<AlerteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConfigService configService = ConfigService();
  bool isLoadingAlerts = false;
  bool isLoadingNotifications = false;
  List<dynamic> alerts = [];
  List<dynamic> notifications = [];
  bool isLoading = false;
  bool isLoadingNotification = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConfiguration();
    fetchAlertes();
    fetchNotification();
  }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  var address = ConfigService().adresse;
  var port = ConfigService().port;

  Future<void> fetchAlertes() async {
    var address = ConfigService().adresse;
    var port = ConfigService().port;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/alert/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      print('Alertes Response Status: ${response.statusCode}');
      print('Alertes Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('Alertes Response Data: $responseData');

        setState(() {
          alerts = responseData;
          isLoading = false;
        });
      } else {
        print('Failed to load alerts');
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching alerts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchNotification() async {
    setState(() {
      isLoadingNotifications = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/notification/getMOb'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      print('Notifications Response Status: ${response.statusCode}');
      print('Notifications Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('Notifications Response Data: $responseData');

        setState(() {
          notifications = responseData;
          isLoadingNotifications = false;
        });
      } else {
        print('Failed to load notifications');
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      setState(() {
        isLoadingNotifications = false;
      });
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$address:$port/api/notification/delete/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.removeWhere((item) => item['id'] == id);
        });
        await fetchNotification();
        print('Notification deleted successfully');
      } else {
        print('Failed to delete notification');
        throw Exception(
            'Failed to delete notification: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting notification: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alertes',
          style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.warning, color: Color.fromRGBO(209, 77, 90, 1)),
              text: 'Alertes',
            ),
            Tab(
              icon: Icon(Icons.notifications_active,
                  color: Color.fromRGBO(209, 77, 90, 1)),
              text: 'Notifications',
            ),
          ],
          labelColor: Color.fromRGBO(209, 77, 90, 1),
          unselectedLabelColor: const Color.fromARGB(133, 124, 124, 124),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoriqueList(alerts, isLoadingAlerts, false),
          _buildHistoriqueList(notifications, isLoadingNotifications, true),
        ],
      ),
    );
  }

  Widget _buildHistoriqueList(
      List<dynamic> historique, bool isLoading, bool isNotification) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historique.isEmpty
              ? Center(
                  child: Text(
                      'No ${isNotification ? 'notifications' : 'alerts'} found'))
              : ListView.builder(
                  itemCount: historique.length,
                  itemBuilder: (context, index) {
                    final item = historique[index];
                    final message = item['message'] ?? 'No message';
                    final createdAt = item['createdAt'] != null
                        ? DateTime.parse(item['createdAt']).toLocal()
                        : DateTime.now();
                    final formattedDate =
                        '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';

                    return Card(
                      elevation:
                          5, // Ajoute une ombre pour donner un effet de profondeur
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Coins arrondis
                      ),
                      color: Colors.white, // Couleur de fond de la carte
                      child: Padding(
                        padding: const EdgeInsets.all(
                            10), // Ajoute un espace autour du contenu
                        child: ListTile(
                          leading: Icon(Icons.warning,
                              color: Colors.redAccent,
                              size: 30), // Icône d'alerte
                          title: Text(
                            'Message: $message',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.black87, // Couleur du texte principal
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  height:
                                      5), // Espace entre le message et la date
                              Text(
                                'Created At: $formattedDate',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors
                                      .black54, // Couleur du texte secondaire
                                ),
                              ),
                            ],
                          ),
                          trailing: isNotification
                              ? IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors
                                          .redAccent), // Icône avec couleur
                                  onPressed: () {
                                    final id = item['_id'];
                                    if (id != null) {
                                      deleteNotification(id);
                                    }
                                  },
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
