import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObtainApiKeyPrompt {
  static const String apiKeyKey = 'apiKey';
  static const String promptKey = 'prompt';
  static const String lastUpdatedKey = 'lastUpdated';

  String apiKey = '';
  String prompt = '';

  // Load chatGPT api key from firestore database
  Future<void> loadApiKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storedApiKey = prefs.getString(apiKeyKey) ?? '';

    final DateTime lastUpdated = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(lastUpdatedKey) ?? 0,
    );
    // print('Api Key last updated $lastUpdated');

    if (DateTime.now().difference(lastUpdated).inDays < 7 &&
        storedApiKey.isNotEmpty) {
      apiKey = storedApiKey;
      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('ApiKey')
              .doc('apiKey')
              .get();

      if (documentSnapshot.exists) {
        final apiKeyValue = documentSnapshot.data()?['apiKey'];
        // print('apikey is: $apiKeyValue');
        if (apiKeyValue != null) {
          apiKey = apiKeyValue;
          prefs.setString(apiKeyKey, apiKey);
          prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      // Handle any errors when accessing Firestore
      print('Error loading Api Key: $e');
    }
  }

  // Load chatGPT prompt from firestore database
  Future<void> loadPrompt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storedPrompt = prefs.getString(promptKey) ?? '';

    final DateTime lastUpdated = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(lastUpdatedKey) ?? 0,
    );
    // print('Prompt last updated $lastUpdated');

    if (DateTime.now().difference(lastUpdated).inDays < 7 &&
        storedPrompt.isNotEmpty) {
      prompt = storedPrompt;
      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('Prompt')
              .doc('prompt')
              .get();

      if (documentSnapshot.exists) {
        final myPrompt = documentSnapshot.data()?['MyPrompt'];
        // print('prompt is: $myPrompt');
        if (myPrompt != null) {
          prompt = myPrompt;
          prefs.setString(promptKey, prompt);
          prefs.setInt(lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      // Handle any errors when accessing Firestore
      print('Error loading Prompt: $e');
    }
  }
}
