import 'package:flutter/material.dart';

import 'location.dart';

class Note {
  final String chapterTitle;
  final String selectedText;
  Location location;

  Note({
    required this.chapterTitle,
    required this.selectedText,
    required this.location,
  });

  // Convert a note object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'chapterTitle': chapterTitle,
      'selectedText': selectedText,
      'location': location.toJson()
    };
  }

  // Create a note object from a JSON map
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      chapterTitle: json['chapterTitle'],
      selectedText: json['selectedText'],
      // location: json['location'],
      location: Location.fromJson(json['location']),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final List<Note> notes;

  final Function(Note) onNoteTap;

  const NotesScreen({
    Key? key,
    required this.notes,
    required this.onNoteTap,
  }) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<bool> selectedStates = [];

  @override
  void initState() {
    super.initState();
    selectedStates = List.generate(widget.notes.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Check if any note is selected
    bool isAnyNoteSelected() {
      return selectedStates.contains(true);
    }

    // select notes
    void toggleNoteSelection(int index) {
      setState(() {
        selectedStates[index] = !selectedStates[index];
      });
    }

    // Delete selected notes
    void deleteSelectedNotes() {
      setState(() {
        final selectedIndexes =
            List.generate(selectedStates.length, (index) => index)
                .where((index) => selectedStates[index])
                .toList();

        // Remove selected notes and their states
        for (var i = selectedIndexes.length - 1; i >= 0; i--) {
          widget.notes.removeAt(selectedIndexes[i]);
          selectedStates.removeAt(selectedIndexes[i]);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Notes')),
        actions: [
          // Show delete icon only when notes are selected
          if (isAnyNoteSelected())
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: deleteSelectedNotes, // Delete selected notes
            ),
        ],
      ),
      body: ListView.builder(
          itemCount: widget.notes.length,
          itemBuilder: (context, index) {
            final note = widget.notes[index];
            final location = note.location; // location from the note object

            return Dismissible(
              // key: Key(note.id.toString()),
              key: UniqueKey(), // Use a unique key for each note
              //Implement code to delete note when swiped
              onDismissed: (direction) {
                deleteSelectedNotes();
              },
              // Set the background color for swipe-to-delete
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete_forever, color: Colors.white),
              ),
              child: ListTile(
                title:
                    Text('${note.chapterTitle} - ${note.location.toString()}'),
                subtitle: Text(note.selectedText),
                // Select/ desect note
                onTap: () {
                  if (isAnyNoteSelected()) {
                    toggleNoteSelection(index);
                  } else {
                    // Navigate to the note page
                    Navigator.of(context).pop(); // Close the Notes page
                    widget.onNoteTap(note); // Notify the parent widget
                  }
                },
                // Select/ desect note
                onLongPress: () {
                  toggleNoteSelection(index);
                },
                tileColor: selectedStates[index] ? Colors.yellowAccent : null,
              ),
            );
          }),
    );
  }
}
