import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
  final String _photoURL = FirebaseAuth.instance.currentUser?.photoURL ?? '';

  void _updateProfile() {
    // Handle updating user profile data here
    // For example, you can use FirebaseAuth.instance.currentUser?.updateProfile method
    // For example, you can use Firebase Authentication to update the user's profile
    // After updating, save the changes to local storage
    ProfileManager.saveDisplayName(_displayName);
    ProfileManager.savePhotoURL(_photoURL);
  }

  void _changeName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = _displayName;
        return AlertDialog(
          title: const Text('Change Name'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _displayName = newName;
                });
                // Save the new name to Firebase or local storage
                _updateProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(_photoURL),
            ),
            const SizedBox(height: 16.0),
            Text(
              _displayName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: _changeName,
              child: const Text('Change Name'),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _updateProfile,
        child: const Text('Save Profile'),
      ),
    );
  }
}

class ProfileManager {
  static const String _displayNameKey = 'display_name';
  static const String _photoURLKey = 'photo_url';

  // Save user's display name to local storage
  static Future<void> saveDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, displayName);
  }

  // Save user's photo URL to local storage
  static Future<void> savePhotoURL(String photoURL) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoURLKey, photoURL);
  }

  // Load user's display name from local storage
  static Future<String?> loadDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNameKey);
  }

  // Load user's photo URL from local storage
  static Future<String?> loadPhotoURL() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoURLKey);
  }
}
