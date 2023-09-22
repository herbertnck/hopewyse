// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class CheckConnection {
//   static Future<void> checkConnectivity(BuildContext context) async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     bool hasInternetConnection =
//         (connectivityResult != ConnectivityResult.none);

//     if (!hasInternetConnection) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Center(child: Text('No Internet Connection!')),
//           behavior: SnackBarBehavior.floating,
//           duration: Duration(seconds: 5),
//         ),
//       );
//     }
//   }

//   static Future<void> refreshPage(BuildContext context) async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Center(child: Text('Loading...')),
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 3),
//       ),
//     );

//     await Future.delayed(const Duration(seconds: 3));

//     checkConnectivity(context);
//   }

//   static Future<void> initializeNotifications() async {
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (String? payload) async {
//       if (payload != null) {
//         //Handle notification click if needed
//       }
//     });
//   }

//   static Future<void> showProgressNotification(
//       FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//       String bookTitle,
//       double progress) async {
//     const int maxProgress = 100;
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       'channel_description',
//       importance: Importance.low,
//       priority: Priority.low,
//       onlyAlertOnce: true,
//       showProgress: true,
//       maxProgress: maxProgress,
//       progress: progress.toInt(),
//       ongoing: true,
//       autoCancel: false,
//       playSound: false,
//     );
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Book Download',
//       'Downloading "$bookTitle"...',
//       platformChannelSpecifics,
//       payload: 'book_download',
//     );
//   }

//   static Future<void> updateProgressNotification(
//       FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//       double progress) async {
//     const int maxProgress = 100;
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       'channel_description',
//       importance: Importance.low,
//       priority: Priority.low,
//       onlyAlertOnce: true,
//       showProgress: true,
//       maxProgress: maxProgress,
//       progress: progress.toInt(),
//       ongoing: true,
//       autoCancel: false,
//       playSound: false,
//     );
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Book Download',
//       // '${widget.book['title']}',
//       platformChannelSpecifics,
//       payload: 'book_download',
//     );
//   }
// }
