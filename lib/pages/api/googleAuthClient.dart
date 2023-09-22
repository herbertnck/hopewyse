import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  // final authHeaders = await account.authHeaders;
  // final authenticateClient= GoogleAuthClient(authHeaders);
  // final DriveApi= drive.DriveApi(authenticateClient);
  
  // final Stream<List<int>>mediaStream = Future.value(
  //   [104, 105]).asStream().asBroadcastStream();
  // var media= new drive.Media(mediaStream, 2);
  // var driveFile= new drive.File();
  // driveFile.name= "hello_world.txt";
  // final resut= await driveApi.files.create(
  //   driveFile, uploadMedia: media);
  // print("Upload result: $result");
}
