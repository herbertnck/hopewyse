import 'dart:async';

import 'package:cosmos_epub/Model/book_progress_model.dart';
import 'package:cosmos_epub/cosmos_epub.dart';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import 'location.dart';
import 'notes.dart';

class ReaderPage extends StatefulWidget {
  final EpubBook epubBook;
  final String selectedChapterId;
  final Function(Note, Location) onAddNote;
  final Function(Location) onUpdateLocation;
  final String epubPath;

  const ReaderPage({
    super.key,
    required this.epubBook,
    required this.selectedChapterId,
    required this.onAddNote,
    required this.onUpdateLocation,
    required this.epubPath,
  });

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final ScrollController _scrollController = ScrollController();
  Location currentLocation = Location(
    chapterIndex: 0,
    startIndex: 0,
    endIndex: 0,
  );

  bool isSelectableMenuVisible = false;

  @override
  void initState() {
    super.initState();
    // Use the saved currentLocation to navigate to the location in the book
    navigateToSavedLocation();
    initializeCosmosEpub ();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Inintialize cosmos Epub reader
  Future<void> initializeCosmosEpub() async {
    WidgetsFlutterBinding.ensureInitialized();

    var _initialized = await CosmosEpub.initialize();

    if(_initialized) {
      // Retrieved the saved book progress if available
      BookProgressModel bookprogress = CosmosEpub.getBookProgress('bookId');
      currentLocation = Location(
        chapterIndex: bookprogress.currentChapterIndex!, 
        startIndex: bookprogress.currentPageIndex!, 
        endIndex: bookprogress.currentPageIndex!
        );
      navigateToSavedLocation();
    }
  }

  // Add a method to navigate to the saved location in the book
  void navigateToSavedLocation() {
    final chapterIndex = currentLocation.chapterIndex;
    final startIndex = currentLocation.startIndex;
    final endIndex = currentLocation.endIndex;
    try {
      // Check if the chapterIndex is valid
      if (chapterIndex >= 0) {
        // Use the saved chapter and page indices to navigate in CosmosEpub
        CosmosEpub.setCurrentPageIndex('bookId', startIndex);
        CosmosEpub.setCurrentChapterIndex('bookId', chapterIndex);
      }
    } catch (e) {
      print('error navigating to saved location: $e');
    }
  }

  // // Method to open the EPUB file using vocsy_epub_viewer
  // Future<void> openEpub() async {
  //   try {
  //     // Set the EPUB viewer configuration
  //     VocsyEpub.setConfig(
  //       themeColor: Theme.of(context).primaryColor,
  //       identifier: "epubBook",
  //       scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
  //       allowSharing: true,
  //       enableTts: true,
  //       nightMode: true,
  //     );

  //     // Listen to the locator stream to track the current location
  //     VocsyEpub.locatorStream.listen((locator) {
  //     });

  //     // Open the EPUB book from your existing widget's epubBook property
  //     VocsyEpub.open(
  //       widget.epubPath, // Provide the path to your EPUB file here
  //       lastLocation: EpubLocator.fromJson({
  //         "bookId": "2239",
  //         "href": "/OEBPS/ch06.xhtml",
  //         "created": 1539934158390,
  //         "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
  //       }),
  //     );
  //   } catch (e) {
  //     print('Error opening EPUB: $e');
  //   }
  // }

  // Method to open the EPUB file using CosmosEpub
  Future<void> openEpub() async {
    try {
      await CosmosEpub.openLocalBook(
        localPath: widget.epubPath, 
        context: context, 
        bookId: 'bookId',
        onPageFlip: (int currentPage, int totalPages) {
          print('Current page is: $currentPage');
        },
        onLastPage: (lastPageIndex) {
          print('This is the last page');
        }
        );
    } catch (e) {
      print('Error opening Epub: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add your UI elements here, including the EpubViewer widget
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('EPUB Reader'),
      // ),
      body: Column(
        children: [
          // Your existing UI elements here...

          // Button to open the EPUB
          ElevatedButton(
            onPressed: () {
              // Call the method to open the EPUB file
              openEpub();
            },
            child: const Text('Open EPUB'),
          ),
        ],
      ),
    );
  }
}
