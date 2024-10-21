import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/screens/config/config_service.dart';

class SimpleHelloDialog extends StatelessWidget {
  final String ticketId;
  final String token;

  final TextEditingController solutionController = TextEditingController();
  var address = ConfigService().adresse;
  var port = ConfigService().port;

  SimpleHelloDialog({super.key, required this.ticketId, required this.token}) {
    print('Received token in constructor: $token');
  }

  Future<void> handleSolved(BuildContext context) async {
    if (solutionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Oops...'),
            content: const Text('Le champ ne doit pas être vide'),
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

    try {
      final solvingData = {'solution': solutionController.text};
      final response = await http.put(
        Uri.parse('$address:$port/api/ticket/solved/$ticketId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(solvingData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark ticket as solved');
      }

      final updatedTicket = json.decode(response.body);
      print(updatedTicket);
      print('Received token in handleSolved: $token');
      Navigator.of(context).pop();
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Oops...'),
            content: Text(error.toString()),
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
  }

  Future<void> showConfirmationDialog(BuildContext context) async {
    final confirmationResult = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de validation'),
          content: const Text('Voulez-vous marquer ce ticket comme résolu ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Close the dialog and confirm
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    if (confirmationResult == true) {
      await handleSolved(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Received token in build method: $token');
    return AlertDialog(
      title: const Text('Solving Ticket'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solution:'),
          TextField(
            controller: solutionController,
            decoration: const InputDecoration(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            showConfirmationDialog(context);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
