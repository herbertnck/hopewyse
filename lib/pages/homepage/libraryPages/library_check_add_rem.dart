import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Check if book is in library
Future<bool> isBookInLibrary(Map<String, dynamic> book) async {
  // Get the app's directory
  var appDirectory = await getExternalStorageDirectory();
  var folderMainPath = appDirectory!.path;
  final libraryFile = File('$folderMainPath/library.json');
  // initialize book
  final newBook = {
    "title": book['title'],
    "author": book['author'],
    "link": book['link'],
    "image": book['image'],
    "size": book['size'],
    "about": book['about'],
    "category": book['category'],
    "genre": book['genre'],
  };

  if (await libraryFile.exists()) {
    // If the library file exists, read its content and parse the JSON
    final String fileContent = await libraryFile.readAsString();
    final List<dynamic> jsonData = jsonDecode(fileContent);
    // Iterate through jsonData and check if newBook is present in the library
    for (final book in jsonData) {
      if (book is Map &&
          book["title"] == newBook["title"] &&
          book["author"] == newBook["author"] &&
          book["link"] == newBook["link"] &&
          book["image"] == newBook["image"] &&
          book["size"] == newBook["size"] &&
          book["about"] == newBook["about"] &&
          book["category"] == newBook["category"] &&
          book["genre"] == newBook["genre"]) {
        return true; // Book found in the library
      }
    }
  }
  return false; // Book title not found in the library
}

// Add book to library
Future<void> addToLibrary(
    BuildContext context, Map<String, dynamic> book) async {
  // Get the app's directory
  var appDirectory = await getExternalStorageDirectory();
  var folderMainPath = appDirectory!.path;
  final libraryFile = File('$folderMainPath/library.json');

  final newBook = {
    "title": book['title'],
    "author": book['author'],
    "link": book['link'],
    "image": book['image'],
    "size": book['size'],
    "about": book['about'],
    "category": book['category'],
    "genre": book['genre'],
  };

  try {
    List<dynamic> libraryData = [];
    if (await libraryFile.exists()) {
      // If file exists Read the contents and parse the json
      final String fileContent = await libraryFile.readAsString();
      libraryData = jsonDecode(fileContent) as List<dynamic>;
    }
    // Check if the book is already in the library based on title, author, and genre
    final bool isBookInLibrary = libraryData.any((book) =>
        book["title"] == newBook["title"] &&
        book["author"] == newBook["author"] &&
        book["link"] == newBook["link"] &&
        book["image"] == newBook["image"] &&
        book["size"] == newBook["size"] &&
        book["about"] == newBook["about"] &&
        book["category"] == newBook["category"] &&
        book["genre"] == newBook["genre"]);
    if (!isBookInLibrary) {
      // Add the new book
      libraryData.add(newBook);
      final String jsonString = jsonEncode(libraryData);
      // Write JSON data to the file with each entry on a new line
      await libraryFile.writeAsString(jsonString.splitMapJoin(
        RegExp(r'}'),
        onMatch: (m) => '}\n',
        onNonMatch: (n) => n,
      ));
    }
  } catch (e) {
    // Error handling for adding to the library
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('Error adding to Library')),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// Remove book from library
Future<void> removeFromLibrary(
    BuildContext context, Map<String, dynamic> book) async {
  // Get the app's directory
  var appDirectory = await getExternalStorageDirectory();
  var folderMainPath = appDirectory!.path;
  final libraryFile = File('$folderMainPath/library.json');
  // Innitialize book
  final newBook = {
    "title": book['title'],
    "author": book['author'],
    "link": book['link'],
    "image": book['image'],
    "size": book['size'],
    "about": book['about'],
    "category": book['category'],
    "genre": book['genre'],
  };

  try {
    if (await libraryFile.exists()) {
      // If the library file exists, read its content and parse the JSON
      final String fileContent = await libraryFile.readAsString();
      final libraryData = jsonDecode(fileContent);
      // Remove the book from the library data.
      libraryData.removeWhere((book) =>
          book["title"] == newBook["title"] &&
          book["author"] == newBook["author"] &&
          book["link"] == newBook["link"] &&
          book["image"] == newBook["image"] &&
          book["size"] == newBook["size"] &&
          book["about"] == newBook["about"] &&
          book["category"] == newBook["category"] &&
          book["genre"] == newBook["genre"]);

      // Save the updated list back to the library file
      final String jsonString = jsonEncode(libraryData);
      // Write JSON data to the file with each entry on a new line
      await libraryFile.writeAsString(jsonString.splitMapJoin(
        RegExp(r'}'),
        onMatch: (m) => '}\n',
        onNonMatch: (n) => n,
      ));
    }
  } catch (e) {
    // Error handling for removing from the library
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('Error removing from Library')),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }
}
