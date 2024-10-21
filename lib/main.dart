// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:todo/api/firebase_api.dart';
// import 'package:todo/screens/pages/alerte.dart';
// import 'package:todo/screens/pages/animationscreen.dart';
// import 'package:todo/screens/pages/notification.dart';
// import 'package:todo/screens/Manager/alerteManager.dart';
// import 'package:todo/screens/Manager/historiqueManager.dart';
// import 'package:todo/screens/Manager/homeManager.dart';
// import 'package:todo/screens/auth/login_screen.dart';
// import 'package:todo/screens/coordinatrice/homeCordinatrice.dart';
// import 'package:todo/screens/home_screen.dart';
// import 'package:todo/screens/tickets/phoneAssigned.dart';
// import 'package:todo/screens/tickets/phoneaccepted.dart';
// import 'package:todo/screens/tickets/phonearrived.dart';
// import 'package:todo/screens/tickets/phonedeparture.dart';
// import 'package:todo/screens/tickets/phoneloading.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:async';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   final firebaseApi = FirebaseApi(navigatorKey);
//   await firebaseApi.initNotification();
//   await firebaseApi.initPushNotification();
//   await initLocalNotifications(); // Initialisation des notifications locales

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');
//   String? email = prefs.getString('email');
//   String? id = prefs.getString('id');
//   String? userRole = prefs.getString('role');

//   print(
//       "Retrieved from SharedPreferences - Token: $token, Email: $email, Role: $userRole, Id: $id");

//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => MyApp(
//         token: token,
//         email: email,
//         userRole: userRole,
//         id: id,
//       ),
//     ),
//   );
// }

// Future<void> initLocalNotifications() async {
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   await _localNotificationsPlugin.initialize(initializationSettings);
// }

// Timer? _sessionTimer;

// void startSessionTimer(BuildContext context) {
//   print('Session timer started');
//   _sessionTimer?.cancel(); // Annuler tout timer existant
//   _sessionTimer =
//       Timer(Duration(hours: 1), () => endSession()); // Timer pour 1 minute
//   // Timer(Duration(seconds: 50), () => endSession());
// }

// void endSession() async {
//   print('Session ended');

//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('token');
//   await prefs.remove('email');
//   await prefs.remove('id');
//   await prefs.remove('role');

//   // Affichage de la popup
//   if (navigatorKey.currentContext != null) {
//     showDialog(
//       context: navigatorKey.currentContext!,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Session Terminée'),
//           content: Text(
//               'Votre session a expiré. Vous serez redirigé vers la page de connexion.'),
//         );
//       },
//     );

//     // Fermeture de la popup et redirection après 3 secondes
//     await Future.delayed(Duration(seconds: 4));
//     Navigator.of(navigatorKey.currentContext!).pop(); // Ferme la popup
//     Navigator.of(navigatorKey.currentContext!)
//         .pushReplacementNamed('/loginpage'); // Redirige vers la page de login
//   } else {
//     print('Context is null, cannot show dialog');
//   }
// }

// class MyApp extends StatelessWidget {
//   final String? token;
//   final String? email;
//   final String? userRole;
//   final String? id;

//   const MyApp({
//     super.key,
//     required this.token,
//     required this.email,
//     required this.id,
//     required this.userRole,
//   });

//   @override
//   Widget build(BuildContext context) {
//     bool isCoordinatrice = userRole == "COORDINATRICE";
//     bool isManager = userRole == "MANAGER";
//     bool isTechnicien = userRole == "TECHNICIEN";

//     final Map<String, WidgetBuilder> coordinatorRoutes = {
//       '/assignedphone': (context) => PhoneAssignedScreen(token: token!),
//       '/notification': (context) => const NotificationScreen(),
//       '/acceptedphone': (context) => PhoneAcceptedScreen(token: token!),
//       '/departurephone': (context) => PhoneDepartureScreen(token: token!),
//       '/arrivedphone': (context) => PhoneArrivedScreen(token: token!),
//       '/loadingphone': (context) => PhoneLoadingScreen(token: token!),
//       '/loginpage': (context) => LoginScreen(),
//       'alert': (context) => AlerteScreen(token: ''),
//     };

//     final Map<String, WidgetBuilder> technicienRoutes = {
//       '/assignedphone': (context) => PhoneAssignedScreen(token: token!),
//       '/notification': (context) => const NotificationScreen(),
//       '/acceptedphone': (context) => PhoneAcceptedScreen(token: token!),
//       '/departurephone': (context) => PhoneDepartureScreen(token: token!),
//       '/arrivedphone': (context) => PhoneArrivedScreen(token: token!),
//       '/loadingphone': (context) => PhoneLoadingScreen(token: token!),
//       '/loginpage': (context) => LoginScreen(),
//       'alert': (context) => AlerteScreen(token: ''),
//     };

//     final Map<String, WidgetBuilder> managerRoutes = {
//       '/alertemanager': (context) => AlerteManagerScreen(token: token!),
//       '/historique': (context) => HistoriqueManagerScreen(token: token!),
//       '/notification': (context) => const NotificationScreen(),
//     };

//     final Map<String, WidgetBuilder> appRoutes = {};
//     if (isCoordinatrice) {
//       appRoutes.addAll(coordinatorRoutes);
//     } else if (isManager) {
//       appRoutes.addAll(managerRoutes);
//     } else if (isTechnicien) {
//       appRoutes.addAll(technicienRoutes);
//     }
//     // scaffoldBackgroundColor: Color.fromARGB(223, 248, 248, 248), blanc
//     //  scaffoldBackgroundColor: Color.fromRGBO(231, 236, 247, 1), // 3 ds cap
//     //  scaffoldBackgroundColor: Color.fromRGBO(239, 243, 251, 1), // 2 ds capture
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Tunisys',
//       navigatorKey: navigatorKey,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 185, 6, 6),
//         ),
//         useMaterial3: true,
//         textTheme: GoogleFonts.poppinsTextTheme(),

//         scaffoldBackgroundColor:
//             Color.fromRGBO(242, 245, 250, 1), // 1 dans capture
//       ),
//       routes: appRoutes,
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/loginpage':
//             return MaterialPageRoute(builder: (context) => LoginScreen());
//           // Ajoutez d'autres routes ici si nécessaire
//           default:
//             return null; // ou une route par défaut
//         }
//       },
//       home: token == null
//           ? IntroScreen()
//           //     ? const LoginScreen()
//           : isCoordinatrice
//               ? HomeCordinatrice(
//                   token: token!,
//                   email:
//                       email ?? '', // Default to empty string if email is null
//                 )
//               : isManager
//                   ? HomeManager(
//                       token: token!,
//                       email: email ??
//                           '', // Default to empty string if email is null
//                     )
//                   : HomeScreen(
//                       token: token!,
//                       email: email ??
//                           '', // Default to empty string if email is null
//                       id: id ?? '', // Default to empty string if id is null
//                     ),
//     );
//   }
// }
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:todo/api/firebase_api.dart';
// import 'package:todo/screens/pages/alerte.dart';
// import 'package:todo/screens/pages/animationscreen.dart';
// import 'package:todo/screens/pages/imagescreen.dart';
// import 'package:todo/screens/pages/notification.dart';
// import 'package:todo/screens/Manager/alerteManager.dart';
// import 'package:todo/screens/Manager/historiqueManager.dart';
// import 'package:todo/screens/Manager/homeManager.dart';
// import 'package:todo/screens/auth/login_screen.dart';
// import 'package:todo/screens/coordinatrice/homeCordinatrice.dart';
// import 'package:todo/screens/home_screen.dart';
// import 'package:todo/screens/tickets/phoneAssigned.dart';
// import 'package:todo/screens/tickets/phoneaccepted.dart';
// import 'package:todo/screens/tickets/phonearrived.dart';
// import 'package:todo/screens/tickets/phonedeparture.dart';
// import 'package:todo/screens/tickets/phoneloading.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:async';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   final firebaseApi = FirebaseApi(navigatorKey);
//   await firebaseApi.initNotification();
//   await firebaseApi.initPushNotification();
//   await initLocalNotifications(); // Initialisation des notifications locales

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');
//   String? email = prefs.getString('email');
//   String? id = prefs.getString('id');
//   String? userRole = prefs.getString('role');

//   print(
//       "Retrieved from SharedPreferences - Token: $token, Email: $email, Role: $userRole, Id: $id");

//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => MyApp(
//         token: token,
//         email: email,
//         userRole: userRole,
//         id: id,
//       ),
//     ),
//   );
// }

// Future<void> initLocalNotifications() async {
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);
//   await _localNotificationsPlugin.initialize(initializationSettings);
// }

// Timer? _sessionTimer;

// void startSessionTimer(BuildContext context) {
//   print('Session timer started');
//   _sessionTimer?.cancel(); // Annuler tout timer existant
//   _sessionTimer =
//       Timer(Duration(hours: 1), () => endSession()); // Timer pour 15 minutes
// }

// void endSession() async {
//   print('Session ended');
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('token');
//   await prefs.remove('email');
//   await prefs.remove('id');
//   await prefs.remove('role');

//   if (navigatorKey.currentContext != null) {
//     showDialog(
//       context: navigatorKey.currentContext!,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Session Terminée'),
//           content: Text(
//               'Votre session a expiré. Vous serez redirigé vers la page de connexion.'),
//         );
//       },
//     );

//     await Future.delayed(Duration(seconds: 4));
//     Navigator.of(navigatorKey.currentContext!).pop(); // Ferme la popup
//     Navigator.of(navigatorKey.currentContext!)
//         .pushReplacementNamed('/loginpage'); // Redirige vers la page de login
//   } else {
//     print('Context is null, cannot show dialog');
//   }
// }

// class MyApp extends StatefulWidget {
//   final String? token;
//   final String? email;
//   final String? userRole;
//   final String? id;

//   const MyApp({
//     super.key,
//     required this.token,
//     required this.email,
//     required this.id,
//     required this.userRole,
//   });

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   Timer? _sessionTimer;
//   static const int sessionTimeoutMinutes =
//       15; // Durée avant expiration de la session
//   bool isFirstLaunch = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkFirstLaunch();
//     WidgetsBinding.instance.addObserver(this);
//     startSessionTimer(BuildContext
//         as BuildContext); // Démarrer le timer lorsque l'application est lancée
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _sessionTimer?.cancel(); // Annuler le timer lors de la destruction
//     super.dispose();
//   }

// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   if (state == AppLifecycleState.resumed) {
//     // App is active, restart the session timer
//     startSessionTimer(context);
//   } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
//     // App is inactive, cancel the session timer
//     _sessionTimer?.cancel();
//   }
// }

// Future<void> _checkFirstLaunch() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isFirst = prefs.getBool('isFirstLaunch') ?? true;

//   if (isFirst) {
//     setState(() {
//       isFirstLaunch = true;
//     });
//     await prefs.setBool('isFirstLaunch', false);
//   } else {
//     setState(() {
//       isFirstLaunch = false;
//     });
//   }
// }

// void startSessionTimer(BuildContext context) {
//   print('Session timer started');
//   _sessionTimer?.cancel(); // Cancel any existing timer
//   _sessionTimer = Timer(sessionTimeoutDuration, () => endSession());
// }

//   void resetSessionTimer() {
//     startSessionTimer(context);
//   }

//   // }
//   Future<void> endSession() async {
//     print('Session ended');
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('email');
//     await prefs.remove('id');
//     await prefs.remove('role');

//     if (navigatorKey.currentContext != null) {
//       showDialog(
//         context: navigatorKey.currentContext!,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Session Terminée'),
//             content: Text(
//                 'Votre session a expiré. Vous serez redirigé vers la page de connexion.'),
//           );
//         },
//       );

//       await Future.delayed(Duration(seconds: 4));
//       Navigator.of(navigatorKey.currentContext!).pop(); // Ferme la popup
//       Navigator.of(navigatorKey.currentContext!)
//           .pushReplacementNamed('/loginpage'); // Redirige vers la page de login
//     } else {
//       print('Context is null, cannot show dialog');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isCoordinatrice = widget.userRole == "COORDINATRICE";
//     bool isManager = widget.userRole == "MANAGER";
//     bool isTechnicien = widget.userRole == "TECHNICIEN";

//     final Map<String, WidgetBuilder> coordinatorRoutes = {
//       '/assignedphone': (context) => PhoneAssignedScreen(token: widget.token!),
//       '/notification': (context) => const NotificationScreen(),
//       '/acceptedphone': (context) => PhoneAcceptedScreen(token: widget.token!),
//       '/departurephone': (context) =>
//           PhoneDepartureScreen(token: widget.token!),
//       '/arrivedphone': (context) => PhoneArrivedScreen(token: widget.token!),
//       '/loadingphone': (context) => PhoneLoadingScreen(token: widget.token!),
//       '/loginpage': (context) => LoginScreen(),
//       '/alert': (context) => AlerteScreen(token: ''),
//     };

//     final Map<String, WidgetBuilder> managerRoutes = {
//       '/alertemanager': (context) => AlerteManagerScreen(token: widget.token!),
//       '/historique': (context) => HistoriqueManagerScreen(token: widget.token!),
//       '/notification': (context) => const NotificationScreen(),
//     };

//     final Map<String, WidgetBuilder> appRoutes = {};
//     if (isCoordinatrice) {
//       appRoutes.addAll(coordinatorRoutes);
//     } else if (isManager) {
//       appRoutes.addAll(managerRoutes);
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Tunisys',
//       navigatorKey: navigatorKey,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 185, 6, 6),
//         ),
//         useMaterial3: true,
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         scaffoldBackgroundColor: Color.fromRGBO(242, 245, 250, 1),
//       ),
//       routes: appRoutes,
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/loginpage':
//             return MaterialPageRoute(builder: (context) => LoginScreen());
//           default:
//             return null; // ou une route par défaut
//         }
//       },
//       home: isFirstLaunch
//           //    ? IntroScreen()
//           ? ImageScreen()
//           : (widget.token == null
//               ? LoginScreen()
//               : isCoordinatrice
//                   ? HomeCordinatrice(
//                       token: widget.token!,
//                       email: widget.email ?? '',
//                     )
//                   : isManager
//                       ? HomeManager(
//                           token: widget.token!,
//                           email: widget.email ?? '',
//                         )
//                       : HomeScreen(
//                           token: widget.token!,
//                           email: widget.email ?? '',
//                           id: widget.id ?? '',
//                         )),
//     );
//   }
// }
// class MyApp extends StatefulWidget {
//   final String? token;
//   final String? email;
//   final String? userRole;
//   final String? id;

//   const MyApp({
//     super.key,
//     required this.token,
//     required this.email,
//     required this.id,
//     required this.userRole,
//   });

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool isFirstLaunch = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkFirstLaunch();

//   }

//   Future<void> _checkFirstLaunch() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? isFirst = prefs.getBool('isFirstLaunch');

//     if (isFirst == null || isFirst) {
//       setState(() {
//         isFirstLaunch = true;
//       });
//       await prefs.setBool('isFirstLaunch', false);
//     } else {
//       setState(() {
//         isFirstLaunch = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isCoordinatrice = widget.userRole == "COORDINATRICE";
//     bool isManager = widget.userRole == "MANAGER";
//     bool isTechnicien = widget.userRole == "TECHNICIEN";

//     final Map<String, WidgetBuilder> coordinatorRoutes = {
//       '/assignedphone': (context) => PhoneAssignedScreen(token: widget.token!),
//       '/notification': (context) => const NotificationScreen(),
//       '/acceptedphone': (context) => PhoneAcceptedScreen(token: widget.token!),
//       '/departurephone': (context) =>
//           PhoneDepartureScreen(token: widget.token!),
//       '/arrivedphone': (context) => PhoneArrivedScreen(token: widget.token!),
//       '/loadingphone': (context) => PhoneLoadingScreen(token: widget.token!),
//       '/loginpage': (context) => LoginScreen(),
//       'alert': (context) => AlerteScreen(token: ''),
//     };

//     final Map<String, WidgetBuilder> managerRoutes = {
//       '/alertemanager': (context) => AlerteManagerScreen(token: widget.token!),
//       '/historique': (context) => HistoriqueManagerScreen(token: widget.token!),
//       '/notification': (context) => const NotificationScreen(),
//     };

//     final Map<String, WidgetBuilder> appRoutes = {};
//     if (isCoordinatrice) {
//       appRoutes.addAll(coordinatorRoutes);
//     } else if (isManager) {
//       appRoutes.addAll(managerRoutes);
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Tunisys',
//       navigatorKey: navigatorKey,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 185, 6, 6),
//         ),
//         useMaterial3: true,
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         scaffoldBackgroundColor: Color.fromRGBO(242, 245, 250, 1),
//       ),
//       routes: appRoutes,
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/loginpage':
//             return MaterialPageRoute(builder: (context) => LoginScreen());
//           default:
//             return null; // ou une route par défaut
//         }
//       },
//       home: isFirstLaunch
//           ? IntroScreen()
//           : (widget.token == null
//               ? LoginScreen()
//               : isCoordinatrice
//                   ? HomeCordinatrice(
//                       token: widget.token!,
//                       email: widget.email ?? '',
//                     )
//                   : isManager
//                       ? HomeManager(
//                           token: widget.token!,
//                           email: widget.email ?? '',
//                         )
//                       : HomeScreen(
//                           token: widget.token!,
//                           email: widget.email ?? '',
//                           id: widget.id ?? '',
//                         )),
//     );
//   }
// }
// void endSession() async {
//   print('Session ended');
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('token');
//   await prefs.remove('email');
//   await prefs.remove('id');
//   await prefs.remove('role');

//   if (navigatorKey.currentContext != null) {
//     showDialog(
//       context: navigatorKey.currentContext!,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Session Terminée'),
//           content: Text(
//               'Votre session a expiré. Vous serez redirigé vers la page de connexion.'),
//         );
//       },
//     );

//     await Future.delayed(Duration(seconds: 4));
//     Navigator.of(navigatorKey.currentContext!).pop(); // Ferme la popup
//     Navigator.of(navigatorKey.currentContext!)
//         .pushReplacementNamed('/loginpage'); // Redirige vers la page de login
//   } else {
//     print('Context is null, cannot show dialog');
//   }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo/api/firebase_api.dart';
import 'package:todo/screens/Manager/alerteManager.dart';
import 'package:todo/screens/Manager/historiqueManager.dart';
import 'package:todo/screens/Manager/homeManager.dart';
import 'package:todo/screens/auth/login_screen.dart';
import 'package:todo/screens/coordinatrice/alerteCoordinatrice.dart';
import 'package:todo/screens/coordinatrice/homeCordinatrice.dart';
import 'package:todo/screens/coordinatrice/phoneTicketsCoordinatrice/phoneAssigned.dart';
import 'package:todo/screens/coordinatrice/phoneTicketsCoordinatrice/phoneaccepted.dart';
import 'package:todo/screens/coordinatrice/phoneTicketsCoordinatrice/phoneloading.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/screens/pages/imagescreen.dart';
import 'package:todo/screens/pages/notification.dart';
import 'package:todo/screens/tickets/phonearrived.dart';
import 'package:todo/screens/tickets/phonedeparture.dart';
import 'firebase_options.dart'; // Assurez-vous d'inclure le fichier FirebaseOptions
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// Global navigator key to manage navigation

// Global navigator key to manage navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print(
        'Message reçu quand l\'application est en premier plan: ${message.messageId}');

    if (message.notification != null) {
      print(
          'Notification: ${message.notification!.title}, ${message.notification!.body}');

      // Affichez la notification manuellement lorsque l'app est active
      await NotificationService.showNotification(message);
    }
  });
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? email = prefs.getString('email');
  String? id = prefs.getString('id');
  String? userRole = prefs.getString('role');

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(
        token: token,
        email: email,
        userRole: userRole,
        id: id,
      ),
    ),
  );
}

Timer? _sessionTimer;

void startSessionTimer() {
  print('Session timer started/restarted');
  _sessionTimer?.cancel(); // Annuler tout timer existant
  _sessionTimer = Timer(Duration(hours: 1), () => endSession());
}

Future<void> endSession() async {
  print('Session ended');
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('email');
  await prefs.remove('id');
  await prefs.remove('role');

  if (navigatorKey.currentContext != null) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Session Terminée'),
          content: Text(
              'Votre session a expiré. Vous serez redirigé vers la page de connexion.'),
        );
      },
    );

    await Future.delayed(Duration(seconds: 4));
    Navigator.of(navigatorKey.currentContext!).pop(); // Ferme la popup
    Navigator.of(navigatorKey.currentContext!)
        .pushReplacementNamed('/loginpage'); // Redirige vers la page de login
  } else {
    print('Context is null, cannot show dialog');
  }
}

class MyApp extends StatefulWidget {
  final String? token;
  final String? email;
  final String? userRole;
  final String? id;

  const MyApp({
    super.key,
    required this.token,
    required this.email,
    required this.id,
    required this.userRole,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    WidgetsBinding.instance.addObserver(this);
    startSessionTimer(); // Démarrer le timer dès que l'application est lancée
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel(); // Annuler le timer lors de la destruction
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // L'application est active, redémarrer le timer
      print('App resumed, restarting session timer');
      startSessionTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // L'application est inactive, annuler le timer
      print('App paused or inactive, canceling session timer');
      _sessionTimer?.cancel();
    }
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirst = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirst) {
      setState(() {
        isFirstLaunch = true;
      });
      await prefs.setBool('isFirstLaunch', false);
    } else {
      setState(() {
        isFirstLaunch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCoordinatrice = widget.userRole == "COORDINATRICE";
    bool isManager = widget.userRole == "MANAGER";
    bool isTechnicien = widget.userRole == "TECHNICIEN";

    final Map<String, WidgetBuilder> coordinatorRoutes = {
      '/assignedphone': (context) => PhoneAssignedScreen(token: widget.token!),
      '/notification': (context) => const NotificationScreen(
            token: '',
          ),
      '/acceptedphone': (context) => PhoneAcceptedScreen(token: widget.token!),
      '/departurephone': (context) =>
          PhoneDepartureScreen(token: widget.token!),
      '/arrivedphone': (context) => PhoneArrivedScreen(token: widget.token!),
      '/loadingphone': (context) => PhoneLoadingScreen(token: widget.token!),
      '/loginpage': (context) => LoginScreen(),
      '/alert': (context) => AlerteScreen(token: ''),
    };

    final Map<String, WidgetBuilder> managerRoutes = {
      '/alertemanager': (context) => AlerteManagerScreen(token: widget.token!),
      '/historique': (context) => HistoriqueManagerScreen(token: widget.token!),
      '/notification': (context) => const NotificationScreen(
            token: '',
          ),
    };

    final Map<String, WidgetBuilder> appRoutes = {};
    if (isCoordinatrice) {
      appRoutes.addAll(coordinatorRoutes);
    } else if (isManager) {
      appRoutes.addAll(managerRoutes);
    }

    return GestureDetector(
      // Détecte n'importe quel tap ou interaction avec l'écran
      onTap: () {
        print('User tapped on screen, restarting session timer');
        startSessionTimer(); // Redémarre le timer à chaque interaction
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tunisys',
        navigatorKey: navigatorKey,
        //  initialRoute: '/',
        // Utilisez les routes définies
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 185, 6, 6),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Color.fromRGBO(242, 245, 250, 1),
        ),
        routes: appRoutes,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/loginpage':
              return MaterialPageRoute(builder: (context) => LoginScreen());
            default:
              return null; // ou une route par défaut
          }
        },
        home: isFirstLaunch
            ? ImageScreen()
            : (widget.token == null
                ? LoginScreen()
                : isCoordinatrice
                    ? HomeCordinatrice(
                        token: widget.token!,
                        email: widget.email ?? '',
                      )
                    : isManager
                        ? HomeManager(
                            token: widget.token!,
                            email: widget.email ?? '',
                          )
                        : HomeScreen(
                            token: widget.token!,
                            email: widget.email ?? '',
                            id: widget.id ?? '',
                          )),
      ),
    );
  }
}
