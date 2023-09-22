
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'dart:async';

import 'package:hopewyse/pages/api/httpauth.dart';


void main() {
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final String _data = 'Some data to save';
  late Timer _saveTimer;

  @override
  void initState() {
    super.initState();
    // Start the timer when the app is launched
    _startTimer();
    // Subscribe to the app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the app is closed
    _saveTimer.cancel(); 
    // Unsubscribe from the app lifecycle events
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save the data when the app is paused or resumed
    if (state == AppLifecycleState.paused || state == AppLifecycleState.resumed) {
      _saveDataToGoogleDrive();
    }
  }

  void _startTimer() {
    // Cancel the existing timer, if any
    _saveTimer.cancel();
    // Start a new timer that runs every 10 minutes
    _saveTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _saveDataToGoogleDrive();
    });
  }

  void _saveDataToGoogleDrive() async {
    // Create a new Drive API client
    final drive = DriveApi(authHttpClient);

    // Create a new file on Google Drive
    final file = File();
    file.name = ['app_data.txt'] as String?;
    // file.name = Stream.fromIterable(_data.codeUnits) as String?;
    // file.name = ByteStream.fromString(_data);
    // file.name = Stream.fromIterable(_data.codeUnits) as String?;
    // file.name = ByteStream.fromBytes(utf8.encode(_data)) as String?;
    file.mimeType = 'text/plain';
    file.parents = ['appDataFolder'];

    // Save the data to the file
 //   final media = Media(file.name, _data.length, _data.codeUnits);
    // final media = Media(_data, _data.length, ByteStream.fromBytes(
    //   utf8.encode(_data)));
    // final media = Media(_data, _data.length, Stream.fromIterable(
    //   _data.codeUnits));
 //   final createdFile = await drive.files.create(file, uploadMedia: media);

    // Print the file ID
 //   print(createdFile.id);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Data will be saved automatically'),
      ),
    );
  }
}
