import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo/screens/FieldsTickets/qrCodeScreenFin.dart';
import 'package:todo/screens/FieldsTickets/SolvedFieldTicket.dart';
import 'package:todo/screens/config/config_service.dart';
import 'package:image/image.dart' as img;

class SimpleHelloDialogField extends StatefulWidget {
  final String ticketId;
  final String token;
  final double ticketLatitude;
  final double ticketLongitude;
  const SimpleHelloDialogField({
    super.key,
    required this.ticketId,
    required this.token,
    required this.ticketLatitude,
    required this.ticketLongitude,
  });

  @override
  _SimpleHelloDialogFieldState createState() => _SimpleHelloDialogFieldState();
}

class _SimpleHelloDialogFieldState extends State<SimpleHelloDialogField> {
  final ConfigService configService = ConfigService();
  final TextEditingController solutionController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  //Image
  bool isImageUploaded = false;
  String? imageBase64;
  String? autreimageBase64;
  String imageError = '';
  String uploadMessage = '';
  //Autre
  bool isAutreImageUploaded = false;
  String uploadAutreMessage = '';
  String autreimageError = '';
  bool isLoading = false;
  String result = '';
  String solutionError = '';
  String errorMessage = '';
  String qrCodeError = '';
  String referenceError = '';
  String scanMessage = '';
  bool isScanCompleted = false;
  String scanError = '';

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final imageBytes = await file.readAsBytes();
    imageBase64 = base64Encode(imageBytes);

    setState(() {
      isImageUploaded = true;
      uploadMessage = 'Fiche uploaded .';
      imageError = '';
    });
  }

  Future<void> uploadAutreImage() async {
      setState(() {
      isLoading = true;  // Début du traitement
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    // Lire les octets de l'image
    final imageBytes = await file.readAsBytes();

    // Décoder l'image
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return;

    // Vérifier les dimensions
    int width = originalImage.width;
    int height = originalImage.height;

    // Redimensionner l'image à 640x480
    img.Image resizedImage =
        img.copyResize(originalImage, width: 640, height: 480);

    // Vérifier les dimensions après redimensionnement
    if (resizedImage.width == 640 && resizedImage.height == 480) {
      print('Dimensions correctes: 640x480');
    } else {
      print(
          'Erreur: Dimensions incorrectes: ${resizedImage.width}x${resizedImage.height}');
    }

    // Convertir l'image en RGB si ce n'est pas déjà le cas
    if (resizedImage.channels != 3) {
      // Créer une nouvelle image en RGB
      img.Image rgbImage = img.Image(resizedImage.width, resizedImage.height);
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          // Récupérer le pixel d'origine
          int pixel = resizedImage.getPixel(x, y);
          // Copier le pixel dans l'image RGB
          rgbImage.setPixel(x, y, pixel);
        }
      }
      resizedImage = rgbImage;
      print(
          'L\'image a été convertie en RGB pour avoir une profondeur de couleur de 24 bits.');
    } else {
      print('Profondeur de couleur correcte: ${resizedImage.channels} canaux');
    }
        int quality = 100;
    List<int> resizedImageBytes;
    do {
      // Encodez l'image en JPEG avec la qualité actuelle
      resizedImageBytes = img.encodeJpg(resizedImage, quality: quality);

      // Calculer la taille de l'image en Ko
      int imageSizeInKB = (resizedImageBytes.length / 1024).floor();
      print('Taille de l\'image avec qualité $quality: ${imageSizeInKB} Ko');

      // Si l'image est supérieure à 100 Ko, réduire la qualité
      if (imageSizeInKB > 100) {
        quality = quality > 20
            ? quality - 5
            : quality - 1; // Réduction conditionnelle
      } else {
        break; // Sortir de la boucle quand la taille est inférieure ou égale à 100 Ko
      }

      // Si la qualité est trop basse, arrêter pour éviter trop de perte de qualité
      if (quality <= 0) {
        print(
            'Impossible de réduire la taille à moins de 100 Ko sans trop de perte de qualité.');
        break;
      }
    } while (resizedImageBytes.length >
        100 * 1024); // Répéter tant que la taille dépasse 100 Ko

    // Convertir en Base64
    autreimageBase64 = base64Encode(resizedImageBytes);

    setState(() {
      isAutreImageUploaded = true;
      uploadAutreMessage = 'Autre image uploaded.';
      autreimageError = '';
    });
  }
    // if (resizedImage.channels != 1) {
    //   // Si ce n'est pas en niveaux de gris
    //   // Créer une nouvelle image en niveaux de gris (1 canal)
    //   img.Image grayImage = img.Image(resizedImage.width, resizedImage.height);

    //   for (int y = 0; y < resizedImage.height; y++) {
    //     for (int x = 0; x < resizedImage.width; x++) {
    //       // Récupérer le pixel d'origine
    //       int pixel = resizedImage.getPixel(x, y);

    //       // Extraire les valeurs RGB
    //       int r = img.getRed(pixel);
    //       int g = img.getGreen(pixel);
    //       int b = img.getBlue(pixel);

    //       // Calculer la luminance (valeur de gris)
    //       int grayValue = (0.299 * r + 0.587 * g + 0.114 * b).round();

    //       // Définir le pixel de l'image en niveaux de gris
    //       grayImage.setPixel(
    //           x, y, img.getColor(grayValue, grayValue, grayValue));
    //     }
    //   }

    //   resizedImage =
    //       grayImage; // Mettre à jour resizedImage pour être l'image en niveaux de gris
    //   print('L\'image a été convertie en niveaux de gris (8 bits).');
    // } else {
    //   print('Profondeur de couleur correcte: ${resizedImage.channels} canaux');
    // }

    // Commencer avec la qualité à 100

/////////////////////// debut ancienne fonction taille //////////////////////////////
    // do {
    //   // Encodez l'image en JPEG avec la qualité actuelle
    //   resizedImageBytes = img.encodeJpg(resizedImage, quality: quality);

    //   // Calculer la taille de l'image en Ko
    //   int imageSizeInKB = resizedImageBytes.length ~/ 1024;
    //   print('Taille de l\'image avec qualité $quality: ${imageSizeInKB} Ko');

    //   // Si l'image est supérieure à 100 Ko, réduire la qualité
    //   if (imageSizeInKB > 100) {
    //     quality =
    //         quality > 10 ? quality - 5 : quality; // Réduction conditionnelle
    //   } else {
    //     break; // Sortir de la boucle quand la taille est inférieure ou égale à 100 Ko
    //   }

    //   // Si la qualité est trop basse, arrêter pour éviter trop de perte de qualité
    //   if (quality <= 0) {
    //     print(
    //         'Impossible de réduire la taille à moins de 100 Ko sans trop de perte de qualité.');
    //     break;
    //   }
    // } while (resizedImageBytes.length >
    //     100 * 1024); // Répéter tant que la taille dépasse 100 Ko

    ////////////////////////////   fin ancienne fonction taille  //////////////////


  // Future<void> uploadAutreImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile == null) return;

  //   final file = File(pickedFile.path);
  //   final imageBytes = await file.readAsBytes();
  //   autreimageBase64 = base64Encode(imageBytes);

  //   setState(() {
  //     isAutreImageUploaded = true;
  //     uploadAutreMessage = 'Autre image uploaded. ';
  //     autreimageError = '';
  //   });
  // }

  Future<void> _loadConfiguration() async {
    await configService.loadConfig(); // Charge la configuration
    setState(() {
      // Met à jour l'interface si nécessaire
    });
  }

  void validateFields() {
    setState(() {
      solutionError = solutionController.text.isEmpty ? '*' : '';
      referenceError = referenceController.text.isEmpty ? '*' : '';
      imageError = imageBase64 == null || imageBase64!.isEmpty ? '*' : '';
      scanError = result == null || result!.isEmpty ? '*' : '';
      referenceError = imageBase64 == null || imageBase64!.isEmpty ? '*' : '';

      errorMessage = (solutionError.isNotEmpty ||
              imageError.isNotEmpty ||
              scanError.isNotEmpty ||
              autreimageError.isNotEmpty ||
              referenceError.isNotEmpty)
          ? 'Veuillez remplir tous les champs obligatoires'
          : '';
    });
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

  var address = ConfigService().adresse;
  var port = ConfigService().port;
  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    //  fetchAssignedTickets();
  }

  Future<double> calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  double ticketLatitude = 0.0; // Assurez-vous de les initialiser correctement
  double ticketLongitude = 0.0;
  Future<void> handleSolved(BuildContext context, double ticketLatitude,
      double ticketLongitude) async {
    var address = ConfigService().adresse;
    var port = ConfigService().port;

    // Check location permissions
    bool hasLocationPermission = await checkLocationPermission();
    if (!hasLocationPermission) {
      print('Permission de localisation refusée');
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      // Retrieve ticket details via API
      final ticketResponse = await http.get(
        Uri.parse('$address:$port/api/ticket/${widget.ticketId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Réponse de l\'API du ticket: ${ticketResponse.body}');

      if (ticketResponse.statusCode != 200) {
        print(
            'Erreur lors de la récupération des détails du ticket: ${ticketResponse.body}');
        throw Exception('Échec de la récupération des détails du ticket');
      }

      final ticketData = json.decode(ticketResponse.body);
      final codeqrStart = ticketData['codeqrStart'];
      final ticketLatitudeFromAPI = ticketData['equipement']['latitude'] ?? 0.0;
      final ticketLongitudeFromAPI =
          ticketData['equipement']['longitude'] ?? 0.0;

      print(
          'Position actuelle : Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      print(
          'Position du ticket : Latitude: $ticketLatitudeFromAPI, Longitude: $ticketLongitudeFromAPI');

      if (ticketLatitudeFromAPI == 0.0 || ticketLongitudeFromAPI == 0.0) {
        print('Erreur : Les coordonnées du ticket sont manquantes');
        showErrorDialog(context,
            message:
                'Les coordonnées du ticket sont manquantes dans la réponse du serveur.');
        return;
      }

      print(
          'Comparaison des QR codes : codeqrStart = $codeqrStart, result = $result');

      if (codeqrStart != result) {
        showErrorDialog(context, message: 'Code QR incorrect');
        return;
      }

      // Calculate the distance between the current position and the ticket's location
      double distance = await calculateDistance(
        position.latitude,
        position.longitude,
        ticketLatitudeFromAPI,
        ticketLongitudeFromAPI,
      );

      print('Distance calculée : $distance mètres');

      if (distance >= 20) {
        // Show location error dialog if the user is too far from the ticket site
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur de localisation'),
              content: Text(
                  'Vous n\'êtes pas au bon site. Veuillez vérifier votre position. Distance : $distance mètres'),
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
        return;
      }

      // Proceed to update the ticket if the user is close enough
      print('Vous êtes au bon site.');

      final Map<String, dynamic> requestBody = {
        'ticketId': widget.ticketId,
        'codeqrEnd': result,
        'solving_time': DateTime.now().toIso8601String(),
        'solution': solutionController.text,
        'fiche_reference': referenceController.text,
        'image': imageBase64,
      };

      if (autreimageBase64 != null && autreimageBase64!.isNotEmpty) {
        requestBody['autre_img'] = autreimageBase64;
      }

      print('Corps de la requête: $requestBody');
      final updateResponse = await http.put(
        Uri.parse(
            '$address:$port/api/ticket/updateTicketSolve/${widget.ticketId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode(requestBody),
      );

      if (updateResponse.statusCode == 200) {
        // Navigate to the solved tickets screen on success
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldSolvedScreen(token: widget.token),
          ),
        );
      } else {
        print(
            'Erreur lors de la mise à jour du ticket: ${updateResponse.body}');
        throw Exception('Échec de la mise à jour du ticket');
      }
    } catch (error) {
      // Error handling
      print('Erreur: $error');
      showErrorDialog(context, message: error.toString());
    }
  }

  // Future<void> handleSolved(BuildContext context, double ticketLatitude,
  //     double ticketLongitude) async {
  //   var address = ConfigService().adresse;
  //   var port = ConfigService().port;

  //   // Vérification des autorisations de localisation
  //   bool hasLocationPermission = await checkLocationPermission();
  //   if (!hasLocationPermission) {
  //     print('Permission de localisation refusée');
  //     return;
  //   }

  //   // Obtention de la position actuelle
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   try {
  //     // Récupération des détails du ticket via l'API
  //     final ticketResponse = await http.get(
  //       Uri.parse('$address:$port/api/ticket/${widget.ticketId}'),
  //       headers: {
  //         'Authorization': 'Bearer ${widget.token}',
  //       },
  //     );

  //     print('Réponse de l\'API du ticket: ${ticketResponse.body}');

  //     if (ticketResponse.statusCode != 200) {
  //       print(
  //           'Erreur lors de la récupération des détails du ticket: ${ticketResponse.body}');
  //       throw Exception('Échec de la récupération des détails du ticket');
  //     }

  //     final ticketData = json.decode(ticketResponse.body);

  //     final codeqrStart = ticketData['codeqrStart'];
  //     final ticketLatitudeFromAPI = ticketData['equipement']['latitude'] ?? 0.0;
  //     final ticketLongitudeFromAPI =
  //         ticketData['equipement']['longitude'] ?? 0.0;

  //     print(
  //         'Position actuelle : Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  //     print(
  //         'Position du ticket : Latitude: $ticketLatitudeFromAPI, Longitude: $ticketLongitudeFromAPI');

  //     if (ticketLatitudeFromAPI == 0.0 || ticketLongitudeFromAPI == 0.0) {
  //       print('Erreur : Les coordonnées du ticket sont manquantes');
  //       showErrorDialog(context,
  //           message:
  //               'Les coordonnées du ticket sont manquantes dans la réponse du serveur.');
  //       return;
  //     }

  //     print(
  //         'Comparaison des QR codes : codeqrStart = $codeqrStart, result = $result');

  //     if (codeqrStart != result) {
  //       showErrorDialog(context, message: 'Code QR incorrect');
  //       return;
  //     }

  //     // Commenter la vérification de la distance

  // //  Calcul de la distance entre la position actuelle et la position du ticket
  //   double distance = await calculateDistance(
  //     position.latitude,
  //     position.longitude,
  //     ticketLatitudeFromAPI,
  //     ticketLongitudeFromAPI,
  //   );

  //   print('Distance calculée : $distance mètres');

  //   if (distance >= 20) {
  //     // Si la distance est supérieure ou égale à 20 mètres
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Erreur de localisation'),
  //           content: Text(
  //               'Vous n\'êtes pas au bon site. Veuillez vérifier votre position. distance : $distance mètres'),
  //           actions: [
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   } else {

  //     // Si la distance est inférieure à 20 mètres, procéder à la mise à jour du ticket
  //     print('Vous êtes au bon site.');

  //     final Map<String, dynamic> requestBody = {
  //       'ticketId': widget.ticketId,
  //       'codeqrEnd': result,
  //       'solving_time': DateTime.now().toIso8601String(),
  //       'solution': solutionController.text,
  //       'fiche_reference': referenceController.text,
  //       'image': imageBase64,
  //     };

  //     if (autreimageBase64 != null && autreimageBase64!.isNotEmpty) {
  //       requestBody['autre_img'] = autreimageBase64;
  //     }

  //     print('Corps de la requête: $requestBody');
  //     final updateResponse = await http.put(
  //       Uri.parse(
  //           '$address:$port/api/ticket/updateTicketSolve/${widget.ticketId}'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${widget.token}',
  //       },
  //       body: json.encode(requestBody),
  //     );

  //     if (updateResponse.statusCode == 200) {
  //       // Si la mise à jour est réussie, naviguer vers l'écran de tickets résolus
  //       Navigator.of(context).popUntil((route) => route.isFirst);
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => FieldSolvedScreen(token: widget.token),
  //         ),
  //       );
  //     } else {
  //       print(
  //           'Erreur lors de la mise à jour du ticket: ${updateResponse.body}');
  //       throw Exception('Échec de la mise à jour du ticket');
  //     }
  //     /*
  //   }
  //   */
  //   } catch (error) {
  //     // Gestion des erreurs
  //     print('Erreur: $error');
  //     showErrorDialog(context, message: error.toString());
  //   }
  // }

  Future<void> submit() async {
    // Validation des champs
    validateFields();

    if (solutionError.isNotEmpty ||
        imageError.isNotEmpty ||
        qrCodeError.isNotEmpty ||
        referenceError.isNotEmpty ||
        autreimageError.isNotEmpty ||
        scanError.isNotEmpty) {
      return; // Ne pas appeler handleSolved si des champs sont invalides
    }

    // Vérifiez que les coordonnées sont disponibles avant de les passer
    if (ticketLatitude != null && ticketLongitude != null) {
      await handleSolved(context, ticketLatitude!, ticketLongitude!);
    } else {
      print('Erreur : Les coordonnées du ticket ne sont pas disponibles.');
    }
  }

  void showErrorDialog(BuildContext context,
      {String message = "Une erreur s'est produite. Veuillez réessayer."}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Solving Ticket'),
        content: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          child: SizedBox(
            height: 400, // Définir une hauteur fixe pour le dialogue
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: solutionController,
                    decoration: InputDecoration(
                      hintText: null,
                      hintStyle: const TextStyle(fontSize: 16),
                      label: Row(
                        children: [
                          Text(
                            'Commentaire ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          if (solutionError.isNotEmpty)
                            Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      labelStyle: TextStyle(
                        color: referenceError.isNotEmpty
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ),
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(
                      hintText: null,
                      hintStyle: const TextStyle(fontSize: 14),
                      label: Row(
                        children: [
                          Text(
                            'Numero fiche ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          if (referenceError.isNotEmpty)
                            Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      labelStyle: TextStyle(
                        color: referenceError.isNotEmpty
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: isImageUploaded ? null : uploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 176, 190, 173),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload,
                              color:
                                  isImageUploaded ? Colors.grey : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isImageUploaded
                                  ? 'Fiche Uploaded'
                                  : 'Upload Fiche ',
                              style: TextStyle(
                                color: isImageUploaded
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (imageError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '*',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 22),
                          ),
                        ),
                    ],
                  ),
                  if (uploadMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        uploadMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  // const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed:
                            isAutreImageUploaded ? null : uploadAutreImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 176, 190, 173),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload,
                              color: isAutreImageUploaded
                                  ? Colors.grey
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAutreImageUploaded
                                  ? 'image uploaded'
                                  : 'Autre image',
                              style: TextStyle(
                                color: isAutreImageUploaded
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (uploadAutreMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        uploadAutreMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: isScanCompleted
                            ? null
                            : () async {
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BarcodeScannerScreen(),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    scanMessage = 'Scanned successfully';
                                    isScanCompleted = true;
                                    this.result = result;
                                    print(
                                        'Scanned QR Code: $result'); // Affichez le résultat dans la console.
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 176, 190, 173),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Scanner',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      if (scanError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '*',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 22),
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  if (scanMessage.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        scanMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: submit,
                      child: const Text(
                        'Soumettre',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 16, 190, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
