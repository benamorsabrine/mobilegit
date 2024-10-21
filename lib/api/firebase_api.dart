import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; // Ajoutez cette ligne si ce n'est pas déjà fait
import 'package:permission_handler/permission_handler.dart';

// Initialisation de Firebase Messaging et des notifications locales

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

  // Initialiser les notifications
  await NotificationService.initialize();

  // Initialiser Firebase Messaging pour gérer les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// Gestion des messages reçus en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService.showNotification(message);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Service de notification
class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configuration du canal de notification Android
  static final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    // 'high_importance_channel', // ID du canal
    // 'High Importance Notifications', // Nom du canal
    // description: 'This channel is used for important notifications.',
    'your_default_channel_id', // ID du canal
    'Your Channel Name', // Nom du canal
    description: 'Description du canal', // Description
    importance: Importance.high,
  );

  // Initialisation des notifications locales
  static Future<void> initialize() async {
    // Paramètres Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Paramètres iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // Paramètres globaux d'initialisation
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialiser Flutter Local Notifications
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Créer un canal de notification pour Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Permission de notification accordée");
    } else {
      print("Permission de notification refusée");
    }
  }

  // Afficher la notification
  static Future<void> showNotification(RemoteMessage message) async {
    String notificationTitle = message.notification?.title ?? 'No Title';
    String notificationBody = message.notification?.body ?? 'No Body';

    // Détails de la notification
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        // _channel.id, // Id du canal
        // _channel.name, // Nom du canal
        // channelDescription: _channel.description,
        'your_default_channel_id',
        'Your Channel Name',
        channelDescription: 'Your Channel Description',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    print('Notification ID: 0');
    print('Title: $notificationTitle');
    print('Body: $notificationBody');

    print('Channel ID: your_default_channel_id');
    await _flutterLocalNotificationsPlugin.show(
      0, // Identifiant unique de la notification
      notificationTitle,
      notificationBody,
      notificationDetails,
    );
  }

  // Initialiser Firebase Messaging
  static Future<void> initPushNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Demander la permission pour les notifications iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Récupérer le token FCM
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Gérer les messages en arrière-plan et lorsque l'application est lancée
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Message reçu lorsque l'application est terminée et relancée
        NotificationService.showNotification(message);
      }
    });

    // Gérer les messages lorsque l'utilisateur clique sur la notification
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   NotificationService.showNotification(message);
    // });
    // Gérer les messages lorsque l'utilisateur clique sur la notification
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   // Ici, tu peux récupérer les données de navigation depuis le message
    //   print("navigation appyé");
    //   if (message.data.containsKey('screen')) {
    //     String route = message.data['screen'];

    //     // Utiliser le Navigator pour rediriger vers l'écran approprié
    //     navigatorKey.currentState?.pushNamed(route);
    //   } else {
    //     // Si aucune route spécifique n'est trouvée, naviguer vers un écran par défaut
    //     navigatorKey.currentState?.pushNamed('/default');
    //   }
    // });

    //appuie sur app est en prmeier niveau
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message reçu pendant que l'application est au premier plan.");
      NotificationService.showNotification(message); // Affiche la notification

      // Si vous souhaitez naviguer vers une route spécifique
      if (message.data.containsKey('screen')) {
        String route = message.data['screen'];
        navigatorKey.currentState?.pushNamed(route);
      }
    });

    // appuie sur app en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty && message.data.containsKey('screen')) {
        String route = message.data['screen'];
        print('Navigating to route: $route'); 
        navigatorKey.currentState?.pushNamed(route);
      } else {
         print('Navigating to default route');
        navigatorKey.currentState?.pushNamed('/default');
      }
    });
  }
}




// /*import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:todo/main.dart';

// class FirebaseApi {
//   // create a new instance
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   //function to initialize notification
//   Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission();
//     //fetch the FCM token for this device
//     final fCMToken = await _firebaseMessaging.getToken();

//     //print the token (normallly you would send this to your server )
//     print('FCM: $fCMToken');
//     initNotification();
//   }

//   //function to handle received messages
//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;
//     //navigate to new screen when message is recived
//     navigatorKey.currentState?.pushNamed(
//       '/notification',
//       arguments: message,
//     );
//   }

//   Future initPushNotification() async {
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//   }
// }
// */
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:todo/main.dart';

// class FirebaseApi {
//   // Create a new instance of FirebaseMessaging
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   // Function to initialize notification
//   Future<void> initNotification() async {
//     // Request permission to show notifications
//     await _firebaseMessaging.requestPermission();

//     // Fetch the FCM token for this device
//     final fCMToken = await _firebaseMessaging.getToken();

//     // Print the token (normally you would send this to your server)
//     print('FCM: $fCMToken');
//   }

//   // Function to handle received messages
//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;

//     // Navigate to the new screen when a message is received
//     navigatorKey.currentState?.pushNamed(
//       '/notification',
//       arguments: message,
//     );
//   }

//   // Function to initialize push notification listeners
//   Future<void> initPushNotification() async {
//     // Handle the case when the app is launched from a terminated state
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

//     // Handle messages when the app is in the background and the user taps on the notification
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

//     // Optionally, handle foreground messages if you want to display an in-app alert
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // Handle the message or show a notification using a package like flutter_local_notifications
//      });
//   }
// }
//

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';

// class FirebaseApi {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final GlobalKey<NavigatorState> navigatorKey;

//   FirebaseApi(this.navigatorKey);

//   Future<void> initLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     // Initialise les notifications locales
//     await _localNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//     );
//   }

//   Future<void> _onDidReceiveNotificationResponse(
//       NotificationResponse notificationResponse) async {
//     final String? payload = notificationResponse.payload;
//     if (payload != null && payload.isNotEmpty) {
//       print('Navigating to: $payload');
//       navigatorKey.currentState?.pushNamed(
//         payload,
//         arguments: payload,
//       );
//     }
//   }

//   Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission();
//     final fCMToken = await _firebaseMessaging.getToken();
//     print('FCM: $fCMToken');
//   }

//   Future<void> _showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'alerts_channel_id',
//       'Alerts',
//       channelDescription: 'Channel for important alerts and notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _localNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       platformChannelSpecifics,
//       payload: message.data['screen'] ?? '', // Use route from data payload
//     );
//   }
//     Future<void> _onSelectNotification(String? payload) async {
//     if (payload != null) {
//       print('Navigating to: $payload'); // Ajoute un log pour vérifier la route
//       navigatorKey.currentState?.pushNamed(
//         payload,
//         arguments: payload,
//       );
//     }
//   }

//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;

//     if (message.notification != null) {
//       _showNotification(message);
//     }
//   }

//   Future<void> initPushNotification() async {
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _navigateToAlertScreen(message);
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       _navigateToAlertScreen(message);
//     });

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       handleMessage(message);
//     });
//   }

//   void _navigateToAlertScreen(RemoteMessage message) {
//     final screen = message.data['screen'] ??
//         '/default'; // Récupère la route depuis le payload

//     if (navigatorKey.currentState != null) {
//       navigatorKey.currentState!.pushNamed(
//         screen,
//         arguments:
//             message.data, // Passe les données de la notification comme argument
//       );
//     }
//   }
// }
// Future<void> initLocalNotifications() async {
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   // await _localNotificationsPlugin.initialize(initializationSettings);
//   await _localNotificationsPlugin.initialize(
//     initializationSettings,
//     onSelectNotification:
//          _onSelectNotification, // Lien vers la méthode qui gère la sélection de notification
//    );
// }
// Future<void> _onSelectNotification(String? payload) async {
//   if (payload != null) {
//     // Utilise le screen depuis le payload et navigue vers l'écran approprié
//     navigatorKey.currentState?.pushNamed(
//       payload,
//       arguments: payload,
//     );
//   }
// }

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';

// class FirebaseApi {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final GlobalKey<NavigatorState> navigatorKey;

//   FirebaseApi(this.navigatorKey);

//   Future<void> initLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _localNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//     );
//   }

//   Future<void> _onDidReceiveNotificationResponse(
//       NotificationResponse notificationResponse) async {
//     final String? payload = notificationResponse.payload;
//     if (payload != null && payload.isNotEmpty) {
//       print('Navigating to: $payload');
//       navigatorKey.currentState?.pushNamed(
//         payload,
//         arguments: payload,
//       );
//     }
//   }

//   Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );

//     final fCMToken = await _firebaseMessaging.getToken();
//     print('FCM Token: $fCMToken');
//   }

//   // Future<void> _showNotification(RemoteMessage message) async {
//   //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   //       AndroidNotificationDetails(
//   //     'alerts_channel_id',
//   //     'Alerts',
//   //     channelDescription: 'Channel for important alerts and notifications.',
//   //     importance: Importance.max,
//   //     priority: Priority.high,
//   //   );
//   //   const NotificationDetails platformChannelSpecifics =
//   //       NotificationDetails(android: androidPlatformChannelSpecifics);

//   //   await _localNotificationsPlugin.show(
//   //     0,
//   //     message.notification?.title ?? 'No title',
//   //     message.notification?.body ?? 'No body',
//   //     platformChannelSpecifics,
//   //     payload: message.data['screen'] ?? '', // Use route from data payload
//   //   );
//   // }
//   Future<void> _showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'high_importance_channel', // Channel ID
//       'High Importance Notifications', // Channel name
//       channelDescription: 'Channel for high importance notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _localNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       platformChannelSpecifics,
//       payload:
//           message.data['screen'] ?? '', // Utilise la route depuis le payload
//     );
//   }

//   Future<void> initPushNotification() async {
//     // Initial message if the app was terminated
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _navigateToAlertScreen(message);
//       }
//     });

//     // Handle message when the app is opened from background
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       _navigateToAlertScreen(message);
//     });

//     // Handle foreground notifications
//     // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //   print('Message received in foreground: ${message.notification?.title}');
//     //   if (message.notification != null) {
//     //     _showNotification(message); // Afficher une notification locale
//     //   }
//     // });
// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //   print('Message reçu: ${message.notification?.title}');
// //   print('Données supplémentaires: ${message.data}');

// //   if (message.notification != null) {
// //     _showNotification(message);  // Afficher la notification locale
// //   }
// // });
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print(
//           "Message received while in foreground: ${message.notification?.title}");

//       // Appelle la fonction pour afficher une notification locale
//       if (message.notification != null) {
//         _showNotification(message);
//       }
//     });
//   }

//   void _navigateToAlertScreen(RemoteMessage message) {
//     final screen = message.data['screen'] ?? '/default'; // Default route

//     if (navigatorKey.currentState != null) {
//       navigatorKey.currentState!.pushNamed(
//         screen,
//         arguments: message.data, // Pass notification data as arguments
//       );
//     }
//   }
// }
