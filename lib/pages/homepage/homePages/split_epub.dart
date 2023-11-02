import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../readPages/book_reader_page.dart';
import '../readPages/reader_page.dart';

class DownloadBook {
  double downloadProgress = 0.0;
  CancelToken? cancelToken;

  Future<void> downloadBook(BuildContext context, dynamic book,
      Function(double progress) onProgressUpdate) async {
    try {
      final appDirectory = await getExternalStorageDirectory();
      final folderPath = "${appDirectory!.path}/ebooks";
      final bookDataPath = "$folderPath/data";
      final coverImage = "${appDirectory.path}/coverimage";
      final dirr = Directory(bookDataPath);
      await dirr.create(recursive: true);
      final dir = Directory(coverImage);
      await dir.create(recursive: true);

      String? epubFilePath;
      try {
        epubFilePath = await findEpubFile(book['title'], folderPath);
      } catch (e) {
        print('Error finding ePub file: $e');
      }

      if (epubFilePath != null) {
        print('Book already downloaded');
        // navigateToReaderPage(context, epubFilePath);
        openEpub(context, epubFilePath);
      } else {
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasInternetConnection =
            (connectivityResult != ConnectivityResult.none);

        if (!hasInternetConnection) {
          showNoInternetToast();
          return;
        }

        epubFilePath = "$folderPath/${book['title']}.epub";
        final coverImagePath = "$coverImage/${book['title']}.png";
        final dataFilePath = "$bookDataPath/${book['title']}.json";

        final dio = Dio();
        cancelToken = CancelToken();

        try {
          await downloadBookFile(
              book['link'], epubFilePath, onProgressUpdate, dio);
        } catch (e) {
          print('Error downloading book file: $e');
          handleError(e, context, onProgressUpdate);
          return;
        }

        // saveBookData(book, dataFilePath);

        // Download the book's image
        final imageUrl = book['image'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            await downloadImage(imageUrl, coverImagePath);
          } catch (e) {
            print('Error downloading book image: $e');
            // Handle the error or provide appropriate feedback.
          }
        }

        // final epubFileContent = await File(epubFilePath).readAsBytes();
        // final epubBook = await EpubReader.readBook(epubFileContent);

        // navigateToReaderPage(context, epubFilePath);
        openEpub(context, epubFilePath);

        onProgressUpdate(1.0); // Set download progress to 100%
      }
    } catch (e) {
      print('epub error $e');
      handleError(e, context, onProgressUpdate);
    }
  }

  // Add a function to download the image and save it to the specified path
  Future<void> downloadImage(String imageUrl, String imagePath) async {
    final dio = Dio();
    final response = await dio.get(imageUrl,
        options: Options(responseType: ResponseType.bytes));
    final imageBytes = response.data as List<int>;

    if (imageBytes.isNotEmpty) {
      await File(imagePath).writeAsBytes(imageBytes);
    } else {
      print('Image data is empty.');
    }
  }

  Future<String?> findEpubFile(String title, String folderPath) async {
    final ebooksDir = Directory(folderPath);

    await for (final entity in ebooksDir.list()) {
      if (entity is File &&
          entity.path.endsWith('.epub') &&
          entity.path.contains(title)) {
        return entity.path;
      }
    }

    return null;
  }

  Future<void> downloadBookFile(String link, String epubFilePath,
      Function(double progress) onProgressUpdate, Dio dio) async {
    await dio.download(
      link,
      epubFilePath,
      onReceiveProgress: (receivedBytes, totalBytes) {
        final progress = receivedBytes / totalBytes;
        onProgressUpdate(progress);
      },
      cancelToken: cancelToken,
    );
  }

  // call for savebookdata method to create json file has been commented
  void saveBookData(dynamic book, String dataFilePath) async {
    final bookData = {
      "title": book['title'] ?? "",
      "author": book['author'] ?? "",
      "chapters": "",
      "description": book['about'] ?? "",
      "location": 0,
      "bookmarks": "",
      "highlights": "",
      "notes": "",
      // Add other relevant book data here,
    };

    final jsonData = const JsonEncoder.withIndent(' ').convert(bookData);
    await File(dataFilePath).writeAsString(jsonData);
    print('JSON data saved');
  }

  void navigateToReaderPage(BuildContext context, String epubFilePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookReaderPage(
          // builder: (context) => ReaderPage(
          path: epubFilePath,
        ),
      ),
    );
  }

  Future<void> openEpub(BuildContext context, String epubFilePath) async {
    try {
      // Set the EPUB viewer configuration
      VocsyEpub.setConfig(
        // themeColor: Theme.of(context).primaryColor,
        identifier: "epubBook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: false,
      );

      // Listen to the locator stream to track the current location
      VocsyEpub.locatorStream.listen((locator) {
        // Handle locator data, convert it to your custom Location object, and update state.
        // Example: Location location = Location.fromJson(locator);
        // Update currentLocation and call onUpdateLocation(location);
      });

      // Open the EPUB book from your existing widget's epubBook property
      VocsyEpub.open(
        epubFilePath, // Provide the path to  EPUB file here
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

  void handleError(dynamic e, BuildContext context,
      Function(double progress) onProgressUpdate) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badResponse) {
        // Restart the download in case of timeout or response errors
        downloadBook(
            context, onProgressUpdate, context as Function(double progress));
      } else if (e.type == DioExceptionType.cancel) {
        cancelToken?.cancel("Book download canceled");
      } else {
        print('Failed to download book');
        showFailedToDownloadToast();
      }
    } else {
      print('Book error $e');
      showNoInternetToast();
    }
  }

  void showNoInternetToast() {
    Fluttertoast.showToast(
      msg: 'No internet connection',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  void showFailedToDownloadToast() {
    Fluttertoast.showToast(
      msg: 'Error: Failed to download book',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}
