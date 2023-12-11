// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'pages/authentication/auth_service.dart';
import 'pages/homepage/chatPages/constant.dart';
import 'pages/homepage/chatPages/store_config.dart';
import 'pages/homepage/notifications.dart';

// Future main() async {
void main() async {
  // configure purchases
  // if (Platform.isIOS || Platform.isMacOS) {
  //   StoreConfig(
  //     store: Store.appStore,
  //     apiKey: appleApiKey,
  //   );
  // } else if (Platform.isAndroid) {
  // Run the app passing --dart-define=AMAZON=true
  const useAmazon = bool.fromEnvironment("amazon");
  StoreConfig(
    store: useAmazon ? Store.amazon : Store.playStore,
    apiKey: useAmazon ? amazonApiKey : googleApiKey,
  );
  // }

  WidgetsFlutterBinding.ensureInitialized();
  await _configureSDK(); // initialize chat package purchases

  // initialize App Firebase connection
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // const kWebRecaptchaSiteKey = '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8';
  // await FirebaseAppCheck.instance.activate(
  //   // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  //   // androidProvider: AndroidProvider.playIntegrity,
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.appAttest,
  // );
  // await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  // FirebaseAppCheck.instance.onTokenChange.listen((token) {
  //   print('token is: $token');
  //   print(token);
  // });

  // Initialize Fluttertoast
  Fluttertoast.showToast;

  // Initialize firebase analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Innitialize flutter download package
  await FlutterDownloader.initialize(
      debug: true, // Set to false to disable printing console logs
      ignoreSsl: true // Set to false to disable working with http links
      );
  FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);

  // Innitialize flutter Local notifications package
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await initializeNotifications();

  runApp(const MyApp());

  //Trigger the notification after the app is launched
  final NotificationPage notificationPage =
      NotificationPage(flutterLocalNotificationsPlugin);
  notificationPage.showNotification();
}

// initialize chat package purchases
Future<void> _configureSDK() async {
  // Enable debug logs before calling `configure`
  // await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;
  }
  await Purchases.configure(configuration);

  await Purchases.enableAdServicesAttributionTokenCollection();
}

//Innitialize Flutter local notifications
Future<void> initializeNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // Add a navigator observer to handle notifications when the app is in the foreground
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        NotificationObserver(), //Custom observer for handling notifications
      ],

      // Check authentication state
      home: AuthService().handleAuthState(),
    );
  }
}

// void callback(String id, int status, int progress) {}
void downloadCallback(String id, int status, int progress) {
  // Handle download status updates here
  print("Download task ($id) is in status ($status) with $progress% progress");
}
