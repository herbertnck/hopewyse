import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hopewyse/pages/authentication/firebasefile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FirebaseApi {
  static bool loading = false;
  Dio dio = Dio();

  static String filePath = "";

  static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<FirebaseFile>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(ref: ref, name: name, url: url);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  static Future downloadFile(Reference ref) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');

    if (await Permission.storage.isGranted) {
      await Permission.storage.request();
      // await startDownload();
      await ref.writeToFile(file);
    } else {
      // await startDownload();
      await ref.writeToFile(file);
    }

    //  await ref.writeToFile(file);
  }

  // static startDownload() async {
  //   Directory? appDocDir = Platform.isAndroid
  //       ? await getExternalStorageDirectory()
  //       : await getApplicationDocumentsDirectory();

  //   // String path = '${appDocDir!.path}/${ref.name}';
  //   File file = File(path);

  //   if (!File(path).existsSync()) {
  //     await file.create();
  //     Dio dio = Dio();
  //     await dio.download(
  //       "ref.writeToFile(file)",
  //       path,
  //         deleteOnError: true, onReceiveProgress: (receivedBytes, totalBytes) {
  //       print((receivedBytes / totalBytes * 100).toStringAsFixed(0));
  //       // setState(() {
  //         loading = true;
  //       // });
  //     }).whenComplete(() {
  //       // setState(() {
  //         loading = false;
  //         filePath = path;
  //       // });
  //     });
  //   } else {
  //     // setState(() {
  //       loading = false;
  //       filePath = path;
  //     // });
  //   }
  // }
}
