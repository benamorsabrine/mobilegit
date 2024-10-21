import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/config/config_service.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final String email;

  const ProfileScreen({super.key, required this.token, required this.email});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? firstname;
  String? lastname;
  String? email;
  String? role;
  String? password;
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  bool isPasswordVisible = false;
  var address = ConfigService().adresse;
  var port = ConfigService().port;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$address:$port/api/user/email/${widget.email}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Afficher les données dans la console
        print('First Name: ${responseData['firstname']}');
        print('Last Name: ${responseData['lastname']}');
        print('Email: ${responseData['email']}');
        print('Role: ${responseData['role']}');
        print('Password: ${responseData['password']}');

        setState(() {
          firstname = responseData['firstname'] as String? ?? '';
          lastname = responseData['lastname'] as String? ?? '';
          email = responseData['email'] as String? ?? '';
          role = responseData['role'] as String? ?? '';
          password = responseData['password'] as String? ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Failed to retrieve user profile data');
      }
    } catch (error) {
      setState(() {
        isError = true;
        errorMessage = error.toString();
        isLoading = false;
      });

      // Afficher l'erreur dans la console
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(
              color: Color.fromRGBO(209, 77, 90, 1),
            )),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        //  centerTitle: true, // Centre le titre de l'AppBar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar section
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color.fromRGBO(209, 77, 90, 1),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: const Color.fromRGBO(231, 236, 250, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Prénom',
                    value: firstname ?? '',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: 'Nom',
                    value: lastname ?? '',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: 'Adresse Email',
                    value: email ?? '',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: 'Role',
                    value: role ?? '',
                    icon: Icons.admin_panel_settings,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: 'Mot de passe',
                    value: password ?? '',
                    icon: Icons.lock,
                    obscureText: !isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color.fromRGBO(209, 77, 90, 1),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromRGBO(209, 77, 90, 1)),
        prefixIcon: Icon(icon, color: const Color.fromRGBO(209, 77, 90, 1)),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 194, 194, 194), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color.fromRGBO(209, 77, 90, 1), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      readOnly: true,
      controller: TextEditingController(text: value),
      obscureText: obscureText,
    );
  }
}
