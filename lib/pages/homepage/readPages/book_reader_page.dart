import 'dart:convert';
import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:flutter/material.dart';

import 'location.dart';
import 'notes.dart';
import 'reader_page.dart';

class BookReaderPage extends StatefulWidget {
  final String path;

  const BookReaderPage({Key? key, required this.path}) : super(key: key);

  @override
  _BookReaderPageState createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  bool showChapters = false;
  late EpubBook epubBook;
  String selectedChapterId = ''; // Store the ID of the selected chapter
  bool isLoading = true; // Add loading state
  List<Note> notes = [];
  Location currentLocation =
      Location(chapterIndex: 0, startIndex: 0, endIndex: 0);
  double readingProgress = 0;
  bool isTopToolbarVisible = false;

  @override
  void initState() {
    super.initState();
    initialize();
    loadNotes();
    loadReadingLocation();
  }

  // Update reading progress and save location when the user exits the book
  @override
  void dispose() {
    saveReadingLocation();
    super.dispose();
  }

  Future<void> initialize() async {
    File file = File(widget.path);

    List<int> bytes = await file.readAsBytes();
    // epubBook = await EpubReader.readBook(bytes);

    setState(() {});
    try {
      print('path is ${widget.path}');
      // epubBook = await EpubReader.readBook(file.readAsBytes());
      epubBook = await EpubReader.readBook(bytes);
      isLoading = false; // Update loading state

      // Call _updateLocation to initialize start and end indexes
      _updateLocation(currentLocation);

      setState(() {});
    } catch (e) {
      // Handle any potential errors during EPUB parsing
      print("Error parsing EPUB: $e");
      setState(() {
        isLoading = false; // Set loading state to false even in case of error
      });
    }
  }

  // Load the saved reading location from the JSON file
  Future<void> loadReadingLocation() async {
    final savedLocation = await Location.loadLocation(widget.path);
    if (savedLocation != null) {
      setState(() {
        currentLocation = savedLocation;
      });
      // Use the 'currentLocation' to navigate to the saved location in the book
      // You may need to implement this navigation logic in 'ReaderPage'
    }
  }

// Save the current reading location when the user exits the book
  Future<void> saveReadingLocation() async {
    await currentLocation.saveLocation(widget.path);
  }

  // update reading progress
  void _updateLocation(Location location) {
    final progress = currentLocation.calculateReadingProgress(epubBook);
    setState(() {
      currentLocation = location;
      readingProgress = progress;
    });
    // Calculate and display the reading progress
    print('Reading Progress: ${(progress * 100).toStringAsFixed(2)}%');
  }

  // Function to add a note and save it to the JSON file
  Future<void> addNote(Note note, Location location) async {
    final noteData = {
      'note': note.toJson(), // Save the note data without the location
      'location': location.toJson(), // Save the location data separately
    };
    final newNote = Note.fromJson(noteData['note']!);
    newNote.location = location;
    notes.add(newNote);
    try {
      // Assuming 'widget.path' is unique to each book
      final filePath = widget.path;
      final file = File('${widget.path}.json');
      print('filepath :$filePath');
      print('path :$file');
      final jsonContents = jsonEncode(notes.map((note) {
        return {
          'note': note.toJson(), // Save the note data with the location
          // 'location': note.location.toJson(),
        };
      }).toList());
      print('jsoncontents: $jsonContents');
      await file.writeAsString(jsonContents);
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  // Load notes from json file in storage
  Future<void> loadNotes() async {
    try {
      final file = File('${widget.path}.json');
      if (await file.exists()) {
        final jsonContents = await file.readAsString();
        final List<dynamic> notesData = jsonDecode(jsonContents);

        // Parse notes from JSON and create notes objects
        notes = notesData.map((data) {
          final noteJson = data['note']; // Extract note data
          // final locationJson = data['location'];

          final note = Note.fromJson(noteJson); // Create note object
          final locationJson = noteJson['location'];
          final location = Location.fromJson(locationJson);

          //Asign the location to the note
          note.location = location;

          return note;
        }).toList();

        setState(() {});
      }
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  // Callback to handle note taps
  void onNoteTap(Note note) {
    final location = note.location;

    // Navigate to the chapter associated with the note
    final chapterIndex = location.chapterIndex;
    if (chapterIndex >= 0 && chapterIndex < epubBook.Chapters!.length) {
      final selectedChapter = epubBook.Chapters![chapterIndex];

      // Update the selected chapter ID to the one associated with the note
      setState(() {
        selectedChapterId =
            selectedChapter.Anchor ?? ''; // Update the selected chapter ID
      });

      // Scroll to the approximate position within the chapter
      final scrollPosition =
          location.calculateScrollPosition(location, epubBook);
      // _scrollToLocation(scrollPosition);
    }
  }

  // Handle the bookmark icon press
  void handleBookmarkIconPress() {
    // Save the current reading location when the user bookmarks
    // currentLocation.saveToFile(widget.path);
    // Implement other bookmark functionality as needed
    // You can toggle bookmarks or navigate to bookmarked locations here
  }

  // Open notes screen
  void _showNotesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotesScreen(
          notes: notes,
          onNoteTap: onNoteTap,
        ),
      ),
    );
  }

  // Callback when a chapter is selected in the ChapterList
  void _onChapterSelected(String chapterId) {
    setState(() {
      selectedChapterId = chapterId;
      showChapters = false;
    });

    // Calculate the initial reading location for the selected chapter
    final chapterIndex =
        epubBook.Chapters!.indexWhere((chapter) => chapter.Anchor == chapterId);

    if (chapterIndex >= 0) {
      final chapter = epubBook.Chapters![chapterIndex];
      final initialLocation = Location(
        chapterIndex: chapterIndex,
        startIndex: 0, // You can set this to any appropriate initial value
        endIndex: 0,
      );

      //update reading progress
      _updateLocation(initialLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || epubBook == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Stack(
        children: [
          // Display the ReaderPage
          ReaderPage(
            epubBook: epubBook,
            selectedChapterId: selectedChapterId,
            onAddNote: addNote,
            onUpdateLocation: _updateLocation,
            // scrollToLocation: _scrollToLocation,
            epubPath: widget.path,
          ),
          // Add the top toolbar
          // if (isTopToolbarVisible)

          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     color: Colors.black.withOpacity(0.5),
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment
          //           .end, // Align the bookmark icon to the right
          //       children: [
          //         IconButton(
          //           icon: const Icon(Icons.bookmark),
          //           onPressed:
          //               handleBookmarkIconPress, // Handle the bookmark icon press
          //           color: Colors.white,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          //bottom tool bar to icons for show menu and settings
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () {
                      setState(() {
                        showChapters = !showChapters;
                      });
                    },
                    color: Colors.white,
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.notes_rounded), // Add notes icon
                  //   onPressed: _showNotesScreen, // Show notes screen
                  //   color: Colors.white,
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.settings),
                  //   onPressed: () {
                  //     // Add your code here for handling settings button press
                  //   },
                  //   color: Colors.white,
                  // ),
                ],
              ),
            ),
          ),
          // Display the ChapterList if showChapters is true
          if (showChapters)
            Positioned(
              left: 20,
              bottom: 60,
              child: ChapterList(
                epubBook: epubBook,
                onChapterSelected: _onChapterSelected,
              ),
            ),

          // Display a progress bar
          // Positioned(
          //     left: 0,
          //     right: 0,
          //     bottom: 90,

          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     color: Colors.red,
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Expanded(
          //           child: LinearProgressIndicator(
          //             value: readingProgress,
          //             backgroundColor: Colors.yellow,
          //             valueColor:
          //                 const AlwaysStoppedAnimation<Color>(Colors.blue),
          //           ),
          //         ),
          //         Text(
          //           // 'Reading Progress: ${(currentLocation.calculateReadingProgress(epubBook) * 100).toStringAsFixed(2)}%',
          //           '${(readingProgress * 100).toStringAsFixed(1)}%',
          //           style: const TextStyle(color: Colors.white),
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}

class ChapterList extends StatelessWidget {
  final EpubBook epubBook;
  final Function(String) onChapterSelected;

  const ChapterList({
    Key? key,
    required this.epubBook,
    required this.onChapterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.7, // Adjust the height as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(8.0),
      width: 200.0,
      child: ListView.builder(
        itemCount: epubBook.Chapters!.length,
        itemBuilder: (context, index) {
          EpubChapter chapter = epubBook.Chapters![index];
          return ListTile(
            title: Text(chapter.Title ?? 'Chapter ${index + 1}'),
            onTap: () {
              onChapterSelected(
                  chapter.Anchor ?? ''); // Provide a default value
            },
          );
        },
      ),
    );
  }
}
