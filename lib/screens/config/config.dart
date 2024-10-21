import 'package:flutter/material.dart';
import 'package:todo/components/text_field.dart';
import 'package:todo/screens/auth/login_screen.dart';
import 'package:todo/utils/toast.dart';
import 'config_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TextEditingController portController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  final ConfigService configService = ConfigService();
  String appVersion = '';
  String buildNumber = '';
  String version = '';
  String appName = '';
  String packageName = '';
  String? errorMessage;

  // @override
  // void initState() {
  //   super.initState();
  //   _initPackageInfo();
  //   _initConfig();
  // }
  @override
  void initState() {
    super.initState();

    // Si ces méthodes sont encore nécessaires
    _initPackageInfo();
    _initConfig();

    // Charger la configuration sauvegardée
    configService.loadConfig();

    // Vérifier que l'adresse et le port sont bien chargés
    print(
        "Adresse: ${configService.adresse}, Port: ${configService.port} , Id${configService.id}");
  }

  void _initConfig() async {
    await configService.loadConfig();
    setState(() {
      // Remplir les champs uniquement si les valeurs ne sont pas vides
      if (configService.adresse.isNotEmpty) {
        adresseController.text =
            configService.adresse.replaceFirst('http://', '');
      }
      portController.text = configService.port;
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      packageName = info.packageName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  Future<void> saveConfig() async {
    if (portController.text.isNotEmpty && adresseController.text.isNotEmpty) {
      configService.adresse = 'http://${adresseController.text}';
      configService.port = portController.text;
      await configService.saveConfig();
      Utils.showToast("Configuration saved successfully");
      // Rediriger l'utilisateur vers l'écran suivant après avoir sauvegardé la configuration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Utils.showToast("Please fill all the fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration',
            style: TextStyle(
              color: Color.fromRGBO(209, 77, 90, 1),
            )),
        backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromRGBO(209, 77, 90, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centrer le texte
                  children: [
                    const SizedBox(height: 90), // Espacement supérieur

                    const Text(
                      "Adresse de serveur",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center, // Centrer le texte
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250, // Réduire la largeur du champ
                      child: TextField(
                        controller: adresseController,
                        decoration: InputDecoration(
                          hintText: "Entrez l'adresse de serveur",
                          hintStyle: TextStyle(
                              color: Colors.grey[400]), // Hint en gris clair
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Espacement entre les champs

                    const Text(
                      "Port de serveur",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center, // Centrer le texte
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250, // Réduire la largeur du champ
                      child: TextField(
                        controller: portController,
                        decoration: InputDecoration(
                          hintText: "Entrez le port de serveur",
                          hintStyle: TextStyle(
                              color: Colors.grey[400]), // Hint en gris clair
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30), // Espacement avant le bouton

                    Center(
                      // Centrer le bouton
                      child: ElevatedButton(
                        onPressed: saveConfig,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: const Color(0xFFEF0000),
                        ),
                        child: const Text('Configurer',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),

            const Spacer(), // Espacement avant le bas de page

            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error retrieving package info");
                } else if (snapshot.connectionState == ConnectionState.done) {
                  PackageInfo? packageInfo = snapshot.data;
                  if (packageInfo != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Version: ${packageInfo.version}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w100,
                              color: Color.fromARGB(255, 80, 80, 80),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Text("No package info available");
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:todo/components/text_field.dart';
// import 'package:todo/screens/auth/login_screen.dart';
// import 'package:todo/utils/toast.dart';
// import 'config_service.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// class ConfigScreen extends StatefulWidget {
//   const ConfigScreen({super.key});

//   @override
//   State<ConfigScreen> createState() => _ConfigScreenState();
// }

// class _ConfigScreenState extends State<ConfigScreen> {
//   TextEditingController portController = TextEditingController();
//   TextEditingController adresseController = TextEditingController();
//   final ConfigService configService = ConfigService();
//   String appVersion = ''; // Store app version
//   String buildNumber = ''; // Store build number
//   String version = '';
//   String appName = '';
//   String packageName = '';
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initPackageInfo();
//     _initConfig();
//   }

//   void _initConfig() async {
//     await configService.loadConfig();
//     setState(() {
//       // S'assurer que l'adresse ne commence pas par "http://"
//       adresseController.text =
//           configService.adresse.replaceFirst('http://', '');
//       portController.text = configService.port;
//     });
//   }

//   Future<void> _initPackageInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     setState(() {
//       appName = info.appName; // Nom de l'application
//       packageName = info.packageName; // Nom du package
//       version = info.version; // Version de l'application
//       buildNumber = info.buildNumber; // Numéro de build
//     });
//   }

//   // Future<void> saveConfig() async {
//   //   if (portController.text.isNotEmpty && adresseController.text.isNotEmpty) {
//   //     // Ajouter "http://" à l'adresse IP entrée
//   //     configService.adresse = 'http://${adresseController.text}';
//   //     configService.port = portController.text;
//   //     await configService.saveConfig();
//   //     Utils.showToast("Configuration saved successfully");
//   //   } else {
//   //     Utils.showToast("Please fill all the fields");
//   //   }
//   // }

//   Future<void> saveConfig() async {
//     if (portController.text.isNotEmpty && adresseController.text.isNotEmpty) {
//       // Ajoute "http://" à l'adresse seulement si ce n'est pas déjà présent
//       configService.adresse = 'http://${adresseController.text}';
//       configService.port = portController.text;
//       await configService.saveConfig(); // Sauvegarde la config
//       Utils.showToast("Configuration saved successfully");
//     } else {
//       Utils.showToast("Please fill all the fields");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Configuration',
//             style: TextStyle(
//               color: Color.fromRGBO(209, 77, 90, 1),
//             )),
//         backgroundColor: const Color.fromRGBO(231, 236, 250, 1),
//         toolbarHeight: 60,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back,
//               color: Color.fromRGBO(209, 77, 90, 1)),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const LoginScreen(),
//               ),
//             );
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment
//               .spaceBetween, // Push the version text to the bottom
//           children: [
//             SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 100),
//                   const Text("Adresse de serveur"),
//                   // Afficher "http://" comme texte fixe et permettre l'édition de la partie IP
//                   Row(
//                     children: [
//                       // Padding pour espacer du texte si nécessaire
//                       const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0),
//                       ),
//                       SizedBox(
//                         width: 200.0, // Définir la largeur souhaitée ici
//                         child: TextField(
//                           controller: adresseController,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             // Tu peux ajouter d'autres décorations ici si nécessaire
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const Text("Port de serveur"),
//                   Container(
//                     width: 300, // Remplace par la largeur souhaitée
//                     child: TextInput(
//                       controller: portController,
//                       label: "Port de serveur",
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: saveConfig,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       textStyle: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       backgroundColor: const Color(0xFFEF0000),
//                     ),
//                     child: const Text(
//                       'Configure',
//                       style: TextStyle(
//                           color: Colors.white), // Set the text color to white
//                     ),
//                   ),
//                   if (errorMessage != null)
//                     Text(
//                       errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                 ],
//               ),
//             ),
//             FutureBuilder<PackageInfo>(
//               future: PackageInfo.fromPlatform(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return const Text("Error retrieving package info");
//                 } else if (snapshot.connectionState == ConnectionState.done) {
//                   PackageInfo? packageInfo = snapshot.data;
//                   if (packageInfo != null) {
//                     return Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize
//                             .min, // Makes sure version info stays compact
//                         children: [
//                           Text(
//                             'Version: ${packageInfo.version}',
//                             style: const TextStyle(
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.w100,
//                               color: Color.fromARGB(255, 80, 80, 80),
//                             ),
//                           ),
//                           //   Text('Build Number: ${packageInfo.buildNumber}'),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return const Text("No package info available");
//                   }
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }