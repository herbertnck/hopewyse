import 'dart:async'; 
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'libraryPages/library_check_add_rem.dart';
import 'homePages/split_epub.dart';

class BookDetails extends StatefulWidget {
  final book;

  const BookDetails({
    super.key,
    // Key? key,
    this.book,
  });

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  double downloadProgress = 0.0;
  CancelToken? cancelToken;
  bool hasInternetConnection = true;
  bool _showLoading = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Instance of DownloadBook class
  final DownloadBook downloader = DownloadBook();

  @override
  void initState() {
    // Method called when the State object is created.
    _checkConnectivity();
    initializeNotifications();
    // _checkIfBookDownloaded();
    super.initState();
  }

  @override
  void dispose() {
    // Method called when the State object is removed.
    cancelToken
        ?.cancel("Book download canceled"); // Cancel any ongoing download.
    super.dispose();
  }

  // checks the internet connectivity status using the Connectivity package.
  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternetConnection = (connectivityResult != ConnectivityResult.none);
    });
  }

  // refreshes the page and checks the internet connectivity status again.
  Future<void> _refreshPage() async {
    // Set loading state to true when refreshing starts
    setState(() {
      _showLoading = true;
    });
    // Add delay to simulate the refresh process
    await Future.delayed(const Duration(seconds: 2));
    await _checkConnectivity(); // Check connectivity status
    // Set loading state to false when refreshing completes
    setState(() {
      _showLoading = false;
    });
  }

  // Sets up display notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        //Handle notification click if needed
      }
    });
  }

  // shows a progress notification when a book is being downloaded.
  Future<void> showProgressNotification(
      String bookTitle, double progress) async {
    final Random random = Random();
    final int notificationId = random.nextInt(10000); // Generate a random ID
    const int maxProgress = 100;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      'channel_description',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress.toInt(),
      ongoing: false, // Set ongoing to false to allow swipe to dismiss
      autoCancel: true, // Automatically cancel the notification when completed
      playSound: false,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      // 0,
      notificationId,
      'Downloading "$bookTitle"...',
      '',
      platformChannelSpecifics,
      payload: 'book_download',
    );
  }

  // updates the progress notification during the download process.
  void updateProgressNotification(double progress) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      'channel_description',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress.toInt(),
      ongoing: false, // Set ongoing to false to allow swipe to dismiss
      autoCancel: true, // Automatically cancel the notification when completed
      playSound: false,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      '${widget.book['title']}',
      '',
      platformChannelSpecifics,
      payload: 'book_download',
    );
  }

  // Method to show a notification when the book download is completed
  Future<void> showDownloadCompleteNotification(String bookTitle) async {
    final Random random = Random();
    final int notificationId = random.nextInt(10000); // Generate a random ID
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      'channel_description',
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: false,
      autoCancel: true,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      // 2,
      notificationId,
      'Download Complete',
      'Book "$bookTitle" downloaded',
      platformChannelSpecifics,
      payload: 'book_download_complete',
    );
  }

  // Method to update the UI with the download progress
  void _updateDownloadProgress(double progress) {
    setState(() {
      downloadProgress = progress;
    });
  }

  // Check if book is in  library
  Future<bool> _isBookInLibrary() async {
    return await isBookInLibrary(widget.book);
  }

  // Add book to library
  Future<void> _addToLibrary() async {
    await addToLibrary(context, widget.book);
    // Update the UI with the book in Library icon
    setState(() {});
  }

  // Remove book from library
  Future<void> _removeFromLibrary() async {
    await removeFromLibrary(context, widget.book);
    // Update the UI with the book in Library icon
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Start of AppBar
      appBar: AppBar(backgroundColor: const Color.fromARGB(200, 58, 168, 193)),
      // End of AppBar

      // Start of body
      body: Column(
        children: [
          // Page loading
          if (_showLoading)
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text('Loading...',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold)),
                )),
          Expanded(
            child: RefreshIndicator(
              //TO referesh page
              onRefresh: _refreshPage,
              child: Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(children: [
                            // To add book title
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "${widget.book['title']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),

                            // To add book image
                            LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth * 0.5,
                                  child: Card(
                                    child: CachedNetworkImage(
                                      imageUrl: widget.book['image'],
                                      fit: BoxFit.cover,
                                      // placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                );
                              },
                            ),

                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // to add read button
                                  SizedBox(
                                    width: 115,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        // onPressed: _handleReadButtonPressed,
                                        onPressed: () {
                                          downloader.downloadBook(
                                            context,
                                            widget.book,
                                            //  _updateDownloadProgress
                                            (progress) {
                                              setState(() {
                                                downloadProgress = progress;
                                              });
                                            },
                                          ); // Call downloadBook function
                                        },
                                        child: const Text("Read",
                                            style: TextStyle(fontSize: 20))),
                                  ),

                                  // to display library button
                                  FutureBuilder<bool>(
                                      future: _isBookInLibrary(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!) {
                                          // Book is in the library
                                          return IconButton(
                                            onPressed:
                                                _removeFromLibrary, // Implement remove functionality
                                            icon: const Icon(Icons
                                                .library_add_check_outlined),
                                            color: Colors.blue,
                                          );
                                        } else {
                                          // Book is not in library
                                          return IconButton(
                                            onPressed:
                                                _addToLibrary, // Implement add functionality
                                            icon: const Icon(Icons.library_add),
                                            color: Colors.blue,
                                          );
                                        }
                                      })
                                ],
                              ),
                            ),

                            // To view book details
                            Container(
                              width: double.infinity, // Cover the whole width
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'About: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 18),
                                    ),
                                    TextSpan(
                                      text: '${widget.book['about']}\n',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                    const TextSpan(
                                      text: 'Size: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 18),
                                    ),
                                    TextSpan(
                                      text: '${widget.book['size']}',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // End of to add book details
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
    // End of body
  }
}
