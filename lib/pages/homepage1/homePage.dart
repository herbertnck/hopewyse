import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'bookDetails.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showLoading = false;
  bool _isConnected = true;
  bool _showNoConnectionSnackBar = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscribeToConnectivityChanges();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_showNoConnectionSnackBar) {
      _showNoConnectionSnackBar = false;
      _showNoConnectionSnackBarIfNeeded();
    }
  }

// Function to check the internet connectivity
  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
    _showNoConnectionSnackBarIfNeeded();
  }

  void _showNoConnectionSnackBarIfNeeded() {
    if (!_isConnected) {
      showNoInternetSnackBar(context);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // Function to show the 'No Internet Connection' Snackbar
  void showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('No Internet Connection!')),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Function to subscribe to connectivity changes
  void _subscribeToConnectivityChanges() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
      _showNoConnectionSnackBarIfNeeded();
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
  Widget build(BuildContext context) {
    return Column(
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
                stream:
                    FirebaseFirestore.instance.collection('books').snapshots(),
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
                              showNoInternetSnackBar(context);
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
    );
  }
}
