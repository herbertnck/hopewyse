import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hopewyse/pages/homepage/menu_drawer.dart';
import 'package:path/path.dart';

// Custom observer to handle notifications
class NotificationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Check if the pushed route is a notification route and handle it accordingly
    if (route is MaterialPageRoute &&
        route.builder != null &&
        route.subtreeContext != null &&
        route.builder!.call(route.subtreeContext!) is NotificationPage) {
      final notificationRoute =
          route.builder!.call(route.subtreeContext!) as NotificationPage;

      notificationRoute.showNotification(); // Show the notification

      NavigatorService.openMenuDrawer();
    }
  }
}

class NotificationPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const NotificationPage(this.flutterLocalNotificationsPlugin, {super.key});

  // Function to show the notification
  Future<void> showNotification() async {
    const AndroidNotificationDetails andoidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '0', // Change to desired channel ID
      'Hope Wyse', // Change to desired channel name
      // 'Todays update', // Change to desired channel description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: andoidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Change to your desired notification ID
      'Notification Title', // Change to your desired notification title
      'Notification Body', // Change to your desired notification body
      platformChannelSpecifics,
      payload: 'item x', // You can pass additional data if needed
    );

    // Open MenuDrawer when notification is clicked
    NavigatorService.openMenuDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Page'),
      ),
      body: const Center(
        child: Text('This is the notification page content.'),
      ),
    );
  }
}

// New rank notification
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    initialize();
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showRankNotification(String rankTitle) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '0', // Channel ID
      'Rank Notication', // Channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Rank Achieved!!', // Notification title
      'Rank: $rankTitle', // Notification body
      platformChannelSpecifics,
      payload: 'rank_notification',
    );
  }
}

// class to handle navigation to menu drawer for new rank
class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static NavigatorState get navigator => navigatorKey.currentState!;

  static void openMenuDrawer() {
    print('notification route to menu drawer');
    navigator.pushReplacementNamed('/menu_drawer');

    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => const MenuDrawer()),
    // );
  }
}
