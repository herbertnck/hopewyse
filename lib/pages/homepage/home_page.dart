import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'book_details.dart';
import 'menu_drawer.dart';
Import 
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showLoading = false;
  bool _isConnected = true;
  bool _showNoConnectionToast = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscribeToConnectivityChanges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_showNoConnectionToast) {
      _showNoConnectionToast = false;
      _showNoConnectionToastIfNeeded();
    }
  }

// Function to check the internet connectivity
  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
    _showNoConnectionToastIfNeeded();
  }

  void _showNoConnectionToastIfNeeded() {
    if (!_isConnected) {
      showNoInternetToast(context);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // Function to show the 'No Internet Connection' Snackbar
  void showNoInternetToast(BuildContext context) {
    Fluttertoast.showToast(
      msg: 'No internet connection',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  // Function to subscribe to connectivity changes
  void _subscribeToConnectivityChanges() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
      _showNoConnectionToastIfNeeded();
    });
  }

  Future<void> _refreshPage() async {
    setState(() {
      _showLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    await _checkConnectivity();
    setState(() {
      _showLoading = false;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer Innitialized
      drawer: const Drawer(child: MenuDrawer()),
      // AppBar innitialized
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(200, 58, 168, 193),
        // forceElevated: true,
        // floating: true,
        // pinned: true,
        // expandedHeight: 100,

        // Display user profile image or icon
        // leading: Builder(
        //   builder: (context) => IconButton(
        //     onPressed: () => Scaffold.of(context).openDrawer(),
        //     // icon: const FaIcon(FontAwesomeIcons.circleUser),
        //     icon: ClipOval(
        //       child: CachedNetworkImage(
        //         imageUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
        //         cacheManager: cacheManager,
        //         width: 40, // Set the desired width of the circular image
        //         height: 40, // Set the desired height of the circular image
        //         // use circle user icon as avater if the network connection
        //         errorWidget: (context, url, error) =>
        //             const FaIcon(FontAwesomeIcons.circleUser),
        //         placeholder: (context, url) =>
        //             const FaIcon(FontAwesomeIcons.circleUser),
        //       ),
        //     ),
        //   ),
        // ),

        leading: Builder(
          builder: (context) => FutureBuilder<File>(
            future: DefaultCacheManager().getSingleFile(
              FirebaseAuth.instance.currentUser?.photoURL ?? '',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const FaIcon(FontAwesomeIcons.circleUser);
              } else if (snapshot.hasError) {
                return const FaIcon(FontAwesomeIcons.circleUser);
              } else if (snapshot.hasData) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: CircleAvatar(
                    backgroundImage: FileImage(snapshot.data!),
                  ),
                );
              } else {
                return IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    // Default icon if no image available
                    icon: const FaIcon(FontAwesomeIcons.circleUser));
              }
            },
          ),
        ),

        flexibleSpace: const FlexibleSpaceBar(
          title: Text(
            'HopeWyse',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      // End of AppBar

      body: Column(
        children: [
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
              onRefresh: _refreshPage,
              child: Material(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                        itemCount: snapshot.data!.docs.length,
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 8,
                                childAspectRatio: 3 / 4),
                        itemBuilder: (context, index) {
                          // obtain books from server
                          var book = snapshot.data!.docs[index].data();
                          // print('book in homepage is $book');

                          return InkWell(
                            onTap: () async {
                              if (_isConnected) {
                                // String? path = await SplitEpub.downloadBook(book);
                                // Navigate to book details page
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => BookDetails(
                                          book: book,
                                          // path: path,
                                        )));
                              } else {
                                showNoInternetToast(context);
                              }
                            },
                            child: Material(
                              elevation: 4, // Adjust shadow depth
                              borderRadius: BorderRadius.circular(6.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: CachedNetworkImage(
                                  imageUrl: book['image'],
                                  fit: BoxFit.cover,

                                  // placeholder: (context, url) =>
                                  //     const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
