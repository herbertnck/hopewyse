import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:selectable/selectable.dart';

import 'notes.dart';
import 'location.dart';

class ReaderPage extends StatefulWidget {
  final EpubBook epubBook;
  final String selectedChapterId;
  final Function(Note, Location) onAddNote;
  final Function(Location) onUpdateLocation;

  // final Function(double) scrollToLocation;

  const ReaderPage({
    Key? key,
    required this.epubBook,
    required this.selectedChapterId,
    required this.onAddNote,
    required this.onUpdateLocation,
    // required this.scrollToLocation,
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
    _scrollController.addListener(_updateLocationOnScroll);
    _updateLocationOnScroll();
    // Use the saved currentLocation to navigate to the location in the book
    navigateToSavedLocation();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateLocationOnScroll);
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
          // if (_scrollController.hasClients) {
          // Scroll to the calculated position
          _scrollController.jumpTo(approximatePosition);
          // }
          // else {
          //   print('scroll controller has no clients');
          // }
        }
      }
    } catch (e) {
      print('error scroll controller $e');
    }
  }

  //Update location progress as the user scrolls across the book
  void _updateLocationOnScroll() {
    final chapterIndex = widget.epubBook.Chapters!
        .indexWhere((chapter) => chapter.Anchor == widget.selectedChapterId);
    if (chapterIndex >= 0) {
      final chapter = widget.epubBook.Chapters![chapterIndex];
      final scrollPosition = _scrollController.position.pixels;
      final totalHeight = _scrollController.position.maxScrollExtent;

      // Calculate the total number of characters in the chapter's text
      final totalCharacters = chapter.HtmlContent!.length;

      // Calculate the current location in Characters
      final currentLocation = ((scrollPosition / totalHeight) * totalCharacters)
          .toInt()
          .clamp(0, totalCharacters);

      // Create a new Location object
      final newLocation = Location(
          chapterIndex: chapterIndex,
          startIndex: currentLocation,
          endIndex: currentLocation + 1);

      setState(() {
        // Update the currentLocation
        this.currentLocation = newLocation;
      });

      // Call the callback to update the location in the parent widget
      widget.onUpdateLocation(newLocation);

      // Update the startIndex and endIndex in the note when the user reads the chapter
      // // Assuming you have a currentNote variable representing the currently selected note
      // if (currentNote != null) {
      //   currentNote.location.startIndex = newLocation.startIndex;
      //   currentNote.location.endIndex = newLocation.endIndex;
      // }
    }
  }

  // Implement a method to scroll to a specific location within the book content
  void _scrollToLocation(double scrollPosition) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(scrollPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    EpubChapter selectedChapter = widget.epubBook.Chapters!.firstWhere(
      (chapter) => chapter.Anchor == widget.selectedChapterId,
      orElse: () => widget.epubBook.Chapters!.first,
    );

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Selectable(
        child: Html(data: selectedChapter.HtmlContent),
        selectWordOnDoubleTap: true,
        popupMenuItems: [
          // Do not add const to the selectable menu item below. it will cause an error
          SelectableMenuItem(
            type: SelectableMenuItemType.copy,
            title: '',
            icon: Icons.content_copy,
          ),
          SelectableMenuItem(
            icon: Icons.star,
            // title: 'Foo',
            title: '',
            isEnabled: (controller) => controller!.isTextSelected,
            handler: (controller) {
              showDialog<void>(
                context: context,
                barrierDismissible: true,
                builder: (builder) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(controller!.getSelection()!.text!),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                },
              );
              return true;
            },
          ),
          SelectableMenuItem(
            // title'addNotes'
            title: '', // Add a menu item for adding notes
            icon: Icons.note_add_outlined,
            isEnabled: (controller) => true, // Enable it always
            handler: (controller) {
              // Implement code to add a note
              final selectedText = controller!.getSelection()!.text!;
              final note = Note(
                chapterTitle: selectedChapter.Title ?? '',
                selectedText: selectedText,
                location: currentLocation,
              );
              // Call the onAddNote function from BookReaderPage to save the note
              widget.onAddNote(note, currentLocation);
              return true;
            },
          ),
        ],
      ),
    );
  }
}
