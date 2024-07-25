import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';

import '../../authentication/auth_service.dart';
import 'about.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
  final String _photoURL = FirebaseAuth.instance.currentUser?.photoURL ?? '';
  // Store the selected Bible type
  // String _selectedBibleType = "English Standard Version";
  late String _selectedBibleType;

  @override
  void initState() {
    super.initState();
    _getSelectedBibleType();
  }

  // Method to set and save the selected Bible type
  Future<void> _setSelectedBibleType(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBibleType = value;
    });
    prefs.setString('selectedBibleType', value);
  }

  // Method to get the selected Bible type, with a default value
  Future<void> _getSelectedBibleType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedBibleType =
        prefs.getString('selectedBibleType') ?? 'English Standard Version';
    setState(() {
      _selectedBibleType = savedBibleType;
    });
  }

  // void _updateProfile() {
  //   // Handle updating user profile data here
  //   // For example, you can use FirebaseAuth.instance.currentUser?.updateProfile method
  //   // For example, you can use Firebase Authentication to update the user's profile
  //   // After updating, save the changes to local storage
  //   ProfileManager.saveDisplayName(_displayName);
  //   ProfileManager.savePhotoURL(_photoURL);
  // }

  // void _changeName() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       String newName = _displayName;
  //       return AlertDialog(
  //         title: const Text('Change Name'),
  //         content: TextField(
  //           onChanged: (value) {
  //             newName = value;
  //           },
  //           decoration: const InputDecoration(labelText: 'New Name'),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               setState(() {
  //                 _displayName = newName;
  //               });
  //               // Save the new name to Firebase or local storage
  //               _updateProfile();
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: <Widget>[
      //       CircleAvatar(
      //         radius: 80,
      //         backgroundImage: NetworkImage(_photoURL),
      //       ),
      //       const SizedBox(height: 16.0),
      //       Text(
      //         _displayName,
      //         style: const TextStyle(
      //           fontSize: 24.0,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       const SizedBox(height: 16.0),
      //       TextButton(
      //         onPressed: _changeName,
      //         child: const Text('Change Name'),
      //       ),
      //     ],
      //   ),
      // ),

      // floatingActionButton: ElevatedButton(
      //   onPressed: _updateProfile,
      //   child: const Text('Save Profile'),
      // ),

      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // User card
            // BigUserCard(
            //   backgroundColor: Colors.red,
            //   userName: _displayName,
            //   userProfilePic: AssetImage(_photoURL),
            // cardActionWidget: SettingsItem(
            //   icons: Icons.edit,
            //   iconStyle: IconStyle(
            //     withBackground: true,
            //     borderRadius: 50,
            //     backgroundColor: Colors.yellow[600],
            //   ),
            //   title: "Modify",
            //   subtitle: "Tap to change your data",
            //   onTap: () {
            //     print("OK");
            //   },
            // ),
            // ),
            SettingsGroup(
              items: [
                // Navigate to the ChooseBibleTypePage
                SettingsItem(
                  onTap: () async {
                    final selectedType = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseBibleTypePage(
                          selectedBibleType: _selectedBibleType,
                        ),
                      ),
                    );
                    // Check if a type was selected
                    if (selectedType != null) {
                      _setSelectedBibleType(selectedType);
                    }
                  },
                  icons: CupertinoIcons.book,
                  iconStyle: IconStyle(),
                  title: 'Bible Type',
                  subtitle: "Select preferred Bible type for Sage",
                ),

                // Dark mode settings
                SettingsItem(
                  onTap: () {},
                  icons: Icons.dark_mode_rounded,
                  iconStyle: IconStyle(
                    iconsColor: Colors.white,
                    withBackground: true,
                    backgroundColor: Colors.red,
                  ),
                  title: 'Dark mode',
                  subtitle: "Automatic",
                  trailing: Switch.adaptive(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),

            // About app settings
            SettingsGroup(
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutPage()),
                    );
                  },
                  icons: Icons.info_rounded,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'About',
                  subtitle: "Learn more about HopeWyse App",
                ),
              ],
            ),

            // Sign out settings
            SettingsGroup(
              settingsGroupTitle: "Account",
              items: [
                SettingsItem(
                  onTap: () {
                    AuthService().signOut();
                  },
                  icons: Icons.exit_to_app_rounded,
                  title: "Sign Out",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Class for choosing the Bible type
class ChooseBibleTypePage extends StatelessWidget {
  final String selectedBibleType;
  const ChooseBibleTypePage({super.key, required this.selectedBibleType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Bible Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your preferred Bible type:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBibleType,
              items: const [
                DropdownMenuItem(
                  value: 'English Standard Version',
                  child: Text('English Standard Version (ESV)'),
                ),
                DropdownMenuItem(
                  value: 'King James Version',
                  child: Text('King James version (KJV)'),
                ),
                DropdownMenuItem(
                  value: 'New American Standard Bible',
                  child: Text('New American Standard Bible (NASB)'),
                ),
                DropdownMenuItem(
                  value: 'New International Version',
                  child: Text('New International Version (NIV)'),
                ),
                DropdownMenuItem(
                  value: 'New Living Translation',
                  child: Text('New Living Translation (NLT)'),
                ),
                DropdownMenuItem(
                  value: 'Revised Standard Version',
                  child: Text('Revised Standard Version (RSV)'),
                ),
              ],
              onChanged: (value) {
                // Handle the selected Bible type
                // You can save it to preferences or perform other actions
                // Navigator.pop(context, value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  // Return selected value to SettingsPage
                  Navigator.pop(context, selectedBibleType);
                },
                child: const Text('SAVE'))
          ],
        ),
      ),
    );
  }
}

// class ProfileManager {
//   static const String _displayNameKey = 'display_name';
//   static const String _photoURLKey = 'photo_url';

//   // Save user's display name to local storage
//   static Future<void> saveDisplayName(String displayName) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_displayNameKey, displayName);
//   }

//   // Save user's photo URL to local storage
//   static Future<void> savePhotoURL(String photoURL) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_photoURLKey, photoURL);
//   }

//   // Load user's display name from local storage
//   static Future<String?> loadDisplayName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_displayNameKey);
//   }

//   // Load user's photo URL from local storage
//   static Future<String?> loadPhotoURL() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_photoURLKey);
//   }

// }
