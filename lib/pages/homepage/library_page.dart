import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'menu_drawer.dart';
import 'homePages/split_epub.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage(
      {Key? key,
      // this.book,
      required this.path})
      : super(key: key);
  // final book;
  final String path;

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<String> _bookTitles = [];
  List<Map<String, dynamic>> _libraryData = []; // Store the parsed library data
  final cacheManager = DefaultCacheManager();

  // Instance of DownloadBook class
  final DownloadBook downloader = DownloadBook();
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBookTitles(); // Call the function to load book titles on init
  }

  // Method to update the UI with the download progress
  void _updateDownloadProgress(double progress) {
    setState(() {
      downloadProgress = progress;
    });
  }

  // Get the book titles from library.json file
  Future<void> _loadBookTitles() async {
    // Get the app's directory
    var appDirectory = await getExternalStorageDirectory();
    var folderMainPath = appDirectory!.path;

    try {
      var file = File('$folderMainPath/library.json');
      if (await file.exists()) {
        // Read the contents of the JSON file
        var jsonString = await file.readAsString();
        // Parse the JSON data into a List
        var jsonData = json.decode(jsonString) as List<dynamic>;
        // Store the parsed library data
        _libraryData = jsonData.cast<Map<String, dynamic>>();
        // Extract the book titles from the JSON data and update the state
        setState(() {
          _bookTitles =
              _libraryData.map((item) => item['title'].toString()).toList();
          // _bookLinks = jsonData.map((item) => item['link'].toString()).toList();
        });
      } else {
        print('Library JSON file does not exist.');
      }
    } catch (e) {
      print('Error loading library data: $e');
    }
  }

  // Get the cover image from coverimage folder
  Future<String?> _getCoverImageForBook(String bookTitle) async {
    // Get coverimage directory
    var appDirectory = await getExternalStorageDirectory();
    var coverImagePath = "${appDirectory!.path}/coverimage/$bookTitle.png";
    //Check if cover image file exists
    if (File(coverImagePath).existsSync()) {
      return coverImagePath;
    } else {
      return null;
    }
  }

  // Inside the _LibraryPageState class

  Future<void> _handleBookTap(
      BuildContext context, Map<String, dynamic> bookData) async {
    // Check if the book data is null or empty
    if (bookData == null || bookData.isEmpty) {
      print("Error: Book data is null or empty.");
      return;
    }
    // Get the book values
    var bookTitle = bookData['title'];
    var bookImage = bookData['image'];
    var bookSize = bookData['size'];
    var bookAuthor = bookData['author'];
    var bookGenre = bookData['genre'];
    var bookAbout = bookData['about'];
    var bookCategory = bookData['category'];
    var bookLink = bookData['link'];

    // Check if the book title is valid and not empty
    // var book = bookTitle;
    var book = {
      // 'image': bookImage,
      // 'size': bookSize,
      'author': bookAuthor,
      'link': bookLink,
      // 'genre': bookGenre,
      'about': bookAbout,
      'title': bookTitle,
      // 'category': bookCategory,
    };
    // book['link'] = bookLink;
    // print('book in librarypage is: $book');

    var downloadBook = DownloadBook(); // Create an instance of DownloadBook

    // Call the downloadBook function from the DownloadBook class to download the selected book
    await downloadBook.downloadBook(
      context,
      book,
      (progress) {
        // Update the UI with the download progress here if needed
        // For example, you could display a progress bar.
        setState(() {
          // Update the UI to show the download progress
          // (if you want to display a progress bar, you can use the 'progress' value)
          downloadProgress = progress;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar innitialized
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(200, 58, 168, 193),
        // Leading icon
        // leading: Builder(
        //   builder: (context) => FutureBuilder<File>(
        //     future: DefaultCacheManager().getSingleFile(
        //       FirebaseAuth.instance.currentUser?.photoURL ?? '',
        //     ),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return const FaIcon(FontAwesomeIcons.circleUser);
        //       } else if (snapshot.hasError) {
        //         return const FaIcon(FontAwesomeIcons.circleUser);
        //       } else if (snapshot.hasData) {
        //         return IconButton(
        //           onPressed: () => Scaffold.of(context).openDrawer(),
        //           icon: CircleAvatar(
        //             backgroundImage: FileImage(snapshot.data!),
        //           ),
        //         );
        //       } else {
        //         return IconButton(
        //             onPressed: () => Scaffold.of(context).openDrawer(),
        //             // Default icon if no image available
        //             icon: const FaIcon(FontAwesomeIcons.circleUser));
        //       }
        //     },
        //   ),
        // ),

        // flexibleSpace: const FlexibleSpaceBar(
        title: const Center(
          child: Text(
            'Library',
            textAlign: TextAlign.center,
          ),
        ),
        // ),
      ),
      // End of AppBar

      // check if library.json file exists and has book titles
      body: _bookTitles.isEmpty
          // Library.json file doesn't exist or has no book titles
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_add,
                    size: 30,
                    color: Colors.blue,
                  ),
                  Center(
                    child: Text(
                      'Click on the icon to add books',
                      style: TextStyle(fontSize: 21),
                    ),
                  ),
                  Center(
                    child: Text(
                      'to your library',
                      style: TextStyle(fontSize: 21),
                    ),
                  ),
                ],
              ),
            )
          // Library.json file exists and has book titles
          // Display book titles in a gridview
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 4),
              // Use _bookTitles list to determine the number of items
              itemCount: _bookTitles.length,
              itemBuilder: (context, index) {
                // Get the book title for the current index
                var bookTitle = _bookTitles[index];
                // print('booktitle is $bookTitle');
                var coverImageFuture = _getCoverImageForBook(bookTitle);

                return InkWell(
                  onTap: () async {
                    // Call downloadBook function
                    // downloader.downloadBook(
                    //   context,
                    //   widget.book,
                    //   _updateDownloadProgress,
                    //   // (progress) {
                    //   //   setState(() {
                    //   //     downloadProgress = progress;
                    //   //   });
                    //   // },
                    // );

                    // var downloadBook = DownloadBook();
                    // await downloadBook.downloadBook(
                    //   context,
                    //   widget.book,
                    //   (progress) {
                    //     // Update the UI with the download progress here if needed
                    //     // For example, you could display a progress bar.
                    //     setState(() {
                    //       // Update the UI to show the download progress
                    //       // (if you want to display a progress bar, you can use the 'progress' value)
                    //     });
                    //   },
                    // );

                    // var book = bookTitle;
                    // await _handleBookTap(context, bookTitle);
                    // Get the corresponding book data from the library data list
                    var selectedBookData = _libraryData[index];
                    // Call the _handleBookTap function with the book data
                    await _handleBookTap(context, selectedBookData);
                  },
                  child: FutureBuilder<String?>(
                    future: coverImageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show the book title while waiting for the future to complete
                        return Text(bookTitle);
                      } else {
                        var coverImage = snapshot.data;
                        if (coverImage != null) {
                          // return Material(
                          //   elevation: 4, // Adjust shadow depth
                          //   borderRadius: BorderRadius.circular(6.0),
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(coverImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                          // );
                        } else {
                          // Show the book title if cover image is not available
                          return Center(child: Text(bookTitle));
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
