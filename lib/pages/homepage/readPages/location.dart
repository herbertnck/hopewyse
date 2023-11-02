import 'dart:convert';
import 'dart:convert';
import 'dart:io';

import 'package:epubx/src/entities/epub_book.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Location {
  final int chapterIndex;
  final int startIndex;
  final int endIndex;

  Location({
    required this.chapterIndex,
    required this.startIndex,
    required this.endIndex,
  });

  // // Override the toString method to provide a formatted representation
  // @override
  // String toString() {
  //   return 'Chapter $chapterIndex, Start: $startIndex, End: $endIndex';
  // }

  // Convert a location object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'chapterIndex': chapterIndex,
      'startIndex': startIndex,
      'endIndex': endIndex,
    };
  }

  // Create a location object from a JSON map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      chapterIndex: json['chapterIndex'],
      startIndex: json['startIndex'],
      endIndex: json['endIndex'],
    );
  }

  // // Convert a location object to a JSON map
  // Map<String, dynamic> toJson() {
  //   return {
  //     'chapterIndex': chapterIndex,
  //     'startIndex': startIndex,
  //     'endIndex': endIndex,
  //   };
  // }

  // Serialize the location to a JSON string
  String toJsonString() {
    final Map<String, dynamic> json = toJson();
    return jsonEncode(json);
  }

  // Deserialize a JSON string into a location object
  static Location fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Location.fromJson(json);
  }

// Save the current location to a JSON file
  Future<void> saveLocation(String filePath) async {
    try {
      final file = File('$filePath.json');
      final locationData = toJson();

      if (await file.exists()) {
        final jsonContents = await file.readAsString();
        final jsonData = jsonDecode(jsonContents);

        jsonData['location'] = locationData;

        await file.writeAsString(jsonEncode(jsonData));
      } else {
        await file.writeAsString(jsonEncode({'location': locationData}));
      }
    } catch (e) {
      print('Error saving location: $e');
    }
  }

// Load saved location from a JSON file
  static Future<Location?> loadLocation(String filePath) async {
    try {
      final file = File('$filePath.json');
      // final file = File('${widget.filePath}.json');

      if (await file.exists()) {
        final jsonContents = await file.readAsString();
        final jsonData = jsonDecode(jsonContents);

        return Location.fromJson(jsonData['location']);
      }
    } catch (e) {
      print('Error loading location: $e');
    }
    return null; // Return null if location couldn't be loaded
  }

  // Calculate book reading progress
  double calculateReadingProgress(EpubBook book) {
    // Calculate the total number of characters in the book
    int totalCharacters = 0;
    int currentLocation = 0;

    for (int i = 0; i < book.Chapters!.length; i++) {
      final chapter = book.Chapters![i];
      totalCharacters += chapter.HtmlContent!.length;

      if (i < chapterIndex) {
        currentLocation += chapter.HtmlContent!.length;
      } else if (i == chapterIndex) {
        currentLocation += startIndex;

        totalCharacters += chapter.HtmlContent!
            .substring(startIndex, endIndex)
            .length; // Add the selected chapter's content length
      }
    }

    print('total characters is $totalCharacters');
    print('Current location is $currentLocation');
    // Calculate the reading progress as a percentage
    double progress = (currentLocation / totalCharacters).clamp(0.0, 1.0);
    return progress;
  }

  double calculateScrollPosition(Location location, EpubBook epubBook) {
    // Ensure the chapter index is valid
    final chapterIndex =
        location.chapterIndex.clamp(0, epubBook.Chapters!.length - 1);

    // Get the selected chapter
    final selectedChapter = epubBook.Chapters![chapterIndex];

    // Get the total number of characters in the chapter's HTML content
    final totalCharacters = selectedChapter.HtmlContent!.length;

    // Calculate the offset based on the character indices
    final startIndex = location.startIndex.clamp(0, totalCharacters);
    final endIndex = location.endIndex.clamp(startIndex, totalCharacters);

    // Calculate the approximate position of the selected text within the chapter
    final approximatePosition =
        (startIndex / totalCharacters) * selectedChapter.HtmlContent!.length;

    return approximatePosition; // Return the calculated scroll position
  }
}
