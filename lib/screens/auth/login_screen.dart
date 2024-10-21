import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/api/firebase_api.dart';
import 'package:todo/components/text_field.dart';
import 'package:todo/main.dart';
import 'package:todo/screens/Manager/homeManager.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/config/config.dart';
import 'package:todo/screens/coordinatrice/homeCordinatrice.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/utils/toast.dart';
import 'package:todo/screens/config/config_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:camera_gallery_image_picker/camera_gallery_image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  String? errorMessage;
  String? fcmToken;
  String lat = '';
  String long = '';
  String locationMessage = 'Current location of the User';
  String appVersion = ''; // Store app version
  String buildNumber = ''; // Store build number
  String version = '';
  String appName = '';
  String packageName = '';
  String _androidId = '';
  //String? deviceId;
  String _deviceId = '';
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initPrefs();
    _getFcmToken();
    _getDeviceID();
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(
        androidInfo); // Affiche toutes les propriétés disponibles de l'appareil

    setState(() {
      _deviceId =
          androidInfo.id; // Essayez d'utiliser 'id' si 'androidId' n'existe pas
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName; // Nom de l'application
      packageName = info.packageName; // Nom du package
      version = info.version; // Version de l'application
      buildNumber = info.buildNumber; // Numéro de build
    });
  }
  // Future<void> _getDeviceId() async {
  //   // Pass context here
  //   String id = await getDeviceId();
  //   setState(() {
  //     deviceId = id;
  //   });
  // }
  // Future<String> getDeviceId() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   String? id; // Make id nullable

  //   if (Theme.of(context).platform == TargetPlatform.android) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     id = androidInfo.id; // Use 'id' instead of 'androidId'
  //   } else if (Theme.of(context).platform == TargetPlatform.iOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     id = iosInfo.identifierForVendor; // Unique ID on iOS
  //   } else {
  //     id = 'Unknown device'; // Handle other platforms if needed
  //   }

  //   return id ?? 'No ID found'; // Return a default message if id is null
  // }
  Future<void> _getFcmToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    fcmToken = await messaging.getToken();
    if (fcmToken == null || fcmToken!.isEmpty) {
      print("Error: FCM Token is invalid or not retrieved.");
      return; // Gérer le cas où le token FCM n'est pas disponible
    }
    print("FCM Token: $fcmToken");
  }

  Future<void> login() async {
    try {
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        if (_deviceId.isEmpty) {
          Utils.showToast("Erreur : DeviceId extrait de l'appareil est vide .");
          return;
        }
        await _getFcmToken();
        var loginBody = {
          "email": emailController.text,
          "password": passwordController.text,
          "fcmToken": fcmToken, // Include the FCM token in the request
          "deviceId": _deviceId,
        };

        print("Attempting to log in with body: $loginBody");
        Utils.showToast("Logging in...");
        var address = ConfigService().adresse;
        var port = ConfigService().port;
        var url = "$address:$port/api/user/loginMob";

        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(loginBody),
        );

        print("Received response with status code: ${response.statusCode}");

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          print("Login successful, response data: $responseData");

          var myToken = responseData["token"];
          var email = responseData["email"];
          var role = responseData["role"];
          var id = responseData["id"];
          var deviceId = responseData["deviceId"];

          Utils.showToast("Logged in successfully");
          // Utils.showToast(email);
          // Utils.showToast(id);
          // Utils.showToast(role);

          print(
              "Token: $myToken, Email: $email, Role: $role, Id: $id , deviceId: $deviceId");

          prefs.setString("token", myToken);
          prefs.setString("email", email);
          prefs.setString("role", role);
          prefs.setString("id", id);
          // Redirection selon le rôle
          if (role == "COORDINATRICE") {
            print("Redirecting to HomeCordinatrice");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeCordinatrice(token: myToken, email: email),
              ),
            );
          } else if (role == "MANAGER") {
            print("Redirecting to HomeManager");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeManager(token: myToken, email: email),
              ),
            );
          } else {
            print("Redirecting to HomeScreen");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(token: myToken, email: email, id: id),
              ),
            );
          }
        } else {
          var errorData = jsonDecode(response.body);
          if (errorData['error'] == "Erreur 003: Accès non autorisé.") {
            Utils.showToast("Erreur 003: Accès non autorisé.");
          } else {
            Utils.showToast(
                "Erreur lors de la connexion: ${errorData['error']}");
          }
        }
      } else {
        Utils.showToast("Veuillez remplir tous les champs.");
      }
    } catch (error) {
      print("Error during login: $error");
      Utils.showToast("Une erreur s'est produite. Veuillez réessayer.");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Utils.showToast("Location services are disabled. Opening settings...");
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Utils.showToast("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Utils.showToast("Location permissions are permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        lat = '${position.latitude}';
        long = '${position.longitude}';
        locationMessage = 'Latitude: $lat, Longitude: $long';
      });
      print('Current position: $lat, $long');
    } catch (e) {
      Utils.showToast("Failed to get location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Empêche le redimensionnement de l'interface utilisateur
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 100.0),
                    child: Image.asset(
                      'assets/logo2.png',
                      width: 250,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextInput(
                    controller: emailController,
                    label: "Email",
                  ),
                  TextInput(
                    controller: passwordController,
                    label: "Password",
                    isPass: true,
                  ),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white), // Couleur du texte
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF0000), // Couleur de fond
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.red, // Couleur de l'icône
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                          width: 3), // Espacement entre l'icône et le texte
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConfigScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Configuration',
                          style:
                              TextStyle(color: Colors.red), // Couleur du texte
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height:
                          120), // Espace supplémentaire pour éviter le débordement
                ],
              ),
            ),
            // Image fixée en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(
                    16.0), // Ajuste le padding si nécessaire
                child: Image.asset(
                  'assets/HI_TSS.png', // Remplace par le chemin de ton image
                  width: 110, // Ajuste la taille de l'image si nécessaire
                  height: 70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
