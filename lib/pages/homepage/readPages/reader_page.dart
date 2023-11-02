import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:selectable/selectable.dart';
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
    Key? key,
    required this.epubBook,
    required this.selectedChapterId,
    required this.onAddNote,
    required this.onUpdateLocation,
    required this.epubPath,
  }) : super(key: key);

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Add a method to navigate to the saved location in the book
  void navigateToSavedLocation() {
    final chapterIndex = currentLocation.chapterIndex;
    final startIndex = currentLocation.startIndex;
    final endIndex = currentLocation.endIndex;
    try {
      // Check if the chapterIndex is valid
      if (chapterIndex >= 0 &&
          chapterIndex < widget.epubBook.Chapters!.length) {
        final selectedChapter = widget.epubBook.Chapters![chapterIndex];
        final totalCharacters = selectedChapter.HtmlContent!.length;

        // Check if startIndex and endIndex are within bounds
        if (startIndex >= 0 &&
            endIndex >= startIndex &&
            endIndex <= totalCharacters) {
          // Calculate the approximate position in the chapter
          final approximatePosition = (startIndex / totalCharacters) *
              selectedChapter.HtmlContent!.length;

          // Check if the _scrollController is attached before jumping
          // Scroll to the calculated position
          _scrollController.jumpTo(approximatePosition);
        }
      }
    } catch (e) {
      print('error scroll controller $e');
    }
  }

  // Method to open the EPUB file using vocsy_epub_viewer
  Future<void> openEpub() async {
    try {
      // Set the EPUB viewer configuration
      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "epubBook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: true,
      );

      // Listen to the locator stream to track the current location
      VocsyEpub.locatorStream.listen((locator) {
        // Handle locator data, convert it to your custom Location object, and update state.
        // Example: Location location = Location.fromJson(locator);
        // Update currentLocation and call onUpdateLocation(location);
      });

      // Open the EPUB book from your existing widget's epubBook property
      VocsyEpub.open(
        // 'bookPath', // Provide the path to your EPUB file here
        widget.epubPath,
        lastLocation: EpubLocator.fromJson({
          "bookId": "2239",
          "href": "/OEBPS/ch06.xhtml",
          "created": 1539934158390,
          "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
        }),
      );
    } catch (e) {
      print('Error opening EPUB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // EpubChapter selectedChapter = widget.epubBook.Chapters!.firstWhere(
    //   (chapter) => chapter.Anchor == widget.selectedChapterId,
    //   orElse: () => widget.epubBook.Chapters!.first,
    // );

    // return SingleChildScrollView(
    //   controller: _scrollController,
    //   padding: const EdgeInsets.all(16.0),
    //   // child: Selectable(
    //   //   child: Html(data: selectedChapter.HtmlContent),
    //   //   selectWordOnDoubleTap: true,
    //   //   popupMenuItems: [
    //   //     // Do not add const to the selectable menu item below. it will cause an error
    //   //     SelectableMenuItem(
    //   //       type: SelectableMenuItemType.copy,
    //   //       title: '',
    //   //       icon: Icons.content_copy,
    //   //     ),
    //   //     SelectableMenuItem(
    //   //       icon: Icons.star,
    //   //       // title: 'Foo',
    //   //       title: '',
    //   //       isEnabled: (controller) => controller!.isTextSelected,
    //   //       handler: (controller) {
    //   //         showDialog<void>(
    //   //           context: context,
    //   //           barrierDismissible: true,
    //   //           builder: (builder) {
    //   //             return AlertDialog(
    //   //               contentPadding: EdgeInsets.zero,
    //   //               content: Container(
    //   //                 padding: const EdgeInsets.all(16),
    //   //                 child: Text(controller!.getSelection()!.text!),
    //   //               ),
    //   //               shape: RoundedRectangleBorder(
    //   //                   borderRadius: BorderRadius.circular(8)),
    //   //             );
    //   //           },
    //   //         );
    //   //         return true;
    //   //       },
    //   //     ),
    //   //     SelectableMenuItem(
    //   //       // title'addNotes'
    //   //       title: '', // Add a menu item for adding notes
    //   //       icon: Icons.note_add_outlined,
    //   //       isEnabled: (controller) => true, // Enable it always
    //   //       handler: (controller) {
    //   //         // Implement code to add a note
    //   //         final selectedText = controller!.getSelection()!.text!;
    //   //         final note = Note(
    //   //           chapterTitle: selectedChapter.Title ?? '',
    //   //           selectedText: selectedText,
    //   //           location: currentLocation,
    //   //         );
    //   //         // Call the onAddNote function from BookReaderPage to save the note
    //   //         widget.onAddNote(note, currentLocation);
    //   //         return true;
    //   //       },
    //   //     ),
    //   //   ],
    //   // ),

    // );
    // Add your UI elements here, including the EpubViewer widget
    return Scaffold(
      appBar: AppBar(
        title: Text('EPUB Reader'),
      ),
      body: Column(
        children: [
          // Your existing UI elements here...

          // Button to open the EPUB
          ElevatedButton(
            onPressed: () {
              // Call the method to open the EPUB file
              openEpub();
            },
            child: Text('Open EPUB'),
          ),

          // EpubViewer widget for rendering the EPUB content
          // Expanded(
          //   child: EpubViewer(),
          // ),
        ],
      ),
    );
  }
}
