import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/FieldsTickets/AssignedFieldTicket.dart';
import 'package:todo/screens/config/config_service.dart';

class NotificationScreen extends StatefulWidget {
  final String token;

  const NotificationScreen({super.key, required this.token});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ConfigService configService = ConfigService();
  bool isLoadingNotifications = false;
  List<dynamic> notifications = [];

  var address = ConfigService().adresse;
  var port = ConfigService().port;

  @override
  void initState() {
    super.initState();
    fetchNotification();
  }

  Future<void> fetchNotification() async {
    print('Token: ${widget.token}');
    setState(() {
      isLoadingNotifications = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/notification/getMob'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Filter notifications to get only those from the last month
        final DateTime oneMonthAgo =
            DateTime.now().subtract(Duration(days: 30));
        notifications = responseData.where((notification) {
          final createdAt = DateTime.parse(notification['createdAt']);
          return createdAt.isAfter(oneMonthAgo);
        }).toList();

        setState(() {
          isLoadingNotifications = false;
        });
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoadingNotifications = false;
      });
      print('Error fetching notifications: $error');
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
          notifications.removeWhere((item) => item['_id'] == id);
        });
        await fetchNotification();
        print('Notification deleted successfully');
      } else {
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
          'Notifications',
          style: TextStyle(color: Color.fromRGBO(209, 77, 90, 1), fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
      ),
      body: _buildNotificationList(notifications, isLoadingNotifications),
    );
  }

  Widget _buildNotificationList(List<dynamic> notifications, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(child: Text('No notifications found'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final message = item['message'] ?? 'No message';
                    final createdAt = item['createdAt'] != null
                        ? DateTime.parse(item['createdAt']).toLocal()
                        : DateTime.now();
                    final formattedDate =
                        '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
return Card(
  elevation: 5,
  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  color: Colors.white,
  child: ListTile(
    leading: Icon(Icons.notifications_active, color: Colors.redAccent, size: 30),
    title: Text(
      'Message: $message',
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
    subtitle: Text('Created At: $formattedDate',
        style: const TextStyle(fontSize: 14, color: Colors.black54)),
    trailing: IconButton(
      icon: const Icon(Icons.delete, color: Colors.redAccent),
      onPressed: () {
        final id = item['_id'];
        if (id != null) {
          deleteNotification(id);
        }
      },
    ),
    onTap: () {
      // Navigate to the Assigned Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FieldAssignedScreen(token: '',)),
      );
    },
  ),
);
                  },
                ),
    );
  }
}
