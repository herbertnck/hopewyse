import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
// import 'package:epubz/epubz.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopewyse/pages/homepage1/book_reader_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

import 'readerPage.dart';

class DownloadBook {
  double downloadProgress = 0.0;
  CancelToken? cancelToken;

  Future<void> downloadBook(BuildContext context, dynamic book,
      Function(double progress) onProgressUpdate) async {
    try {
      var appDirectory = await getExternalStorageDirectory();
      var folderPath = "${appDirectory!.path}/ebooks";
      var bookDataPath = "$folderPath/data";
      var coverImage = "${appDirectory.path}/coverimage";
      var dirr = Directory(bookDataPath);
      await dirr.create(recursive: true);
      var dir = Directory(coverImage);
      await dir.create(recursive: true);

      // Check if the book is already downloaded in the app storage subfolders

      var epubFilePath;
      // await for (var entity in Directory(folderPath).list()) {
      //   if (entity is Directory) {
      //     // var bookPath = "${entity.path}/${book['title']}.epub";
      //     var bookPath = "${book['title']}.epub";
      //     var file = File(bookPath);
      //     if (await file.exists()) {
      //       epubFilePath = bookPath;
      //       break;
      //     }
      //   }
      // }

      var ebooksDir = Directory(folderPath);
      await for (var entity in ebooksDir.list()) {
        if (entity is File) {
          if (entity.path.endsWith('.epub') &&
              entity.path.contains(book['title'])) {
            epubFilePath = entity.path;
            break;
          }
        }
      }

      if (epubFilePath != null) {
        print('book already downloaded');
        // Book is already downloaded, navigate to ReaderPage to read it
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => ReaderPage(path: epubFilePath),
            builder: (context) => BookReaderPage(
              path: epubFilePath,
              // epubContent: epubFilePath,
            ),
          ),
        );
      } else {
        // Book is not downloaded, initiate the download process
        var connectivityResult = await Connectivity().checkConnectivity();
        var hasInternetConnection =
            (connectivityResult != ConnectivityResult.none);
        if (!hasInternetConnection) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text('No Internet Connection!')),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        // create unique folder
        // var uniqueFolderName = const Uuid().v4();
        // var uniqueFolderNamePath = "$folderPath/$uniqueFolderName";
        var epubFilePath = "$folderPath/${book['title']}.epub";
        var coverImagePath = "$coverImage/${book['title']}.png";
        var dataFilePath = "$bookDataPath/${book['title']}.json";

        // var dir = Directory(uniqueFolderNamePath);
        // await dir.create(recursive: true);

        //Download the book
        var dio = Dio();
        cancelToken = CancelToken();
        await dio.download(
          book['link'],
          epubFilePath,
          onReceiveProgress: (receivedBytes, totalBytes) {
            // if (mounted) {
            // setState(() {
            downloadProgress = receivedBytes / totalBytes;
            // updateProgressNotification(downloadProgress * 100);
            onProgressUpdate(downloadProgress);
            // });
            // }
          },
          cancelToken: cancelToken,
        );

        // Read the ePub file content as bytes
        var epubFileContent = await File(epubFilePath).readAsBytes();
        //Parse the epub book
        var epubBook = await EpubReader.readBook(epubFileContent);
        // Save cover image
        img.Image? coverImageData;
        // Save cover image
        if (epubBook.CoverImage == null) {
          final data = await rootBundle.load("assets/images/cover.png");
          coverImageData = img.decodeImage(data.buffer.asUint8List())!;
        } else {
          coverImageData = epubBook.CoverImage!;
        }

        // Save cover image as PNG
        var coverImageFile = File(coverImagePath);
        await coverImageFile.writeAsBytes(img.encodePng(coverImageData!));

        // Extract book data and save to json file
        var bookData = {
          "title": book['title'],
          "author": book['author'],
          "chapters": "",
          "description": book['about'],
          "location": 0,
          "bookmarks": "",
          "highlights": "",
          "notes": "",
          // Add other relevant book data here,
        };

        //Save book data as json
        var jsonData = const JsonEncoder.withIndent(' ').convert(bookData);
        await File(dataFilePath).writeAsString(jsonData);
        print('json data saved');

        // Show the downloaded book
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => ReaderPage(path: epubFilePath),
            builder: (context) => BookReaderPage(
              path: epubFilePath,
              // bookChapters: BookChapters,
              // epubContent: epubFilePath,
            ),
          ),
        );

        // notification to show book is downloaded
        // updateProgressNotification(100);
        onProgressUpdate(1.0); // Set download progress to 100%

        // Show download complete notification
        // showDownloadCompleteNotification(book['title']);
      }
    } catch (e) {
      // handle errors
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.badResponse) {
          // Restart the download in case of timeout or response errors
          await downloadBook(
              book, onProgressUpdate, context as Function(double progress));
        } else if (e.type == DioExceptionType.cancel) {
          // Cancel the download
          cancelToken?.cancel("Book download canceled");
          // delete the unique folder created
          // if (uniqueFolderName != null){
          //   var folderPath = filePath.substring(0, filePath.lastIndexOf('/'));
          //   var folder = Directory(folderPath);
          //   if (folder.existsSync()) {
          //     await folder.delete(recursive: true);
          //   }
          // }
          // return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text('Error: Failed to download book')),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('Book error $e');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Center(child: Text('Error: No Internet Connection!!')),
        //     behavior: SnackBarBehavior.floating,
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
    }
  }
}
