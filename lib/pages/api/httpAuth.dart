import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

// Replace these values with your own client ID and client secret
const String clientId = 'YOUR_CLIENT_ID';
const String clientSecret = 'YOUR_CLIENT_SECRET';

// The list of scopes that you want to request
final List<String> scopes = [DriveApi.driveScope];

// Create an authenticated HTTP client
// final authHttpClient =  clientViaUserConsent(
//   ClientId(clientId, clientSecret),
//   scopes,
//   (url) async {
//     // Open the URL in the default browser to get the authorization code
//     await launch(url);
//   },
// );

AutoRefreshingAuthClient authHttpClient = 
 clientViaUserConsent(
  ClientId(clientId, clientSecret),
  scopes,
  (url) async {
    // Open the URL in the default browser to get the authorization code
    await launch(url);
  },
) as AutoRefreshingAuthClient;