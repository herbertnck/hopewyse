import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hopewyse/pages/authentication/loginpage.dart';
import 'package:hopewyse/pages/homepage1/home.dart';
import 'package:path_provider/path_provider.dart';

import '../homepage1/homepage.dart';

class AuthService {
  String folderPath =
      ""; // Declare folderPath variable outside _createDirectory()

  // Determine if the user is authenticated.
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        return FutureBuilder<void>(
          future: _createDirectory(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while the directory is being created
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Handle any errors that occurred during directory creation
              return const Text('Error creating directory');
            } else {
              // Directory has been created, return the appropriate widget based on snapshot data
              if (snapshot.hasData) {
                return const Home();
              } else {
                return const Home();
              }
            }
          },
        );
      },
    );
  }

  Future<void> _createDirectory() async {
    var appDirectory = await getExternalStorageDirectory();
    folderPath = "${appDirectory!.path}/ebooks";
    var dir = Directory(folderPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Profile image
  getProfileImage() {
    if (FirebaseAuth.instance.currentUser!.photoURL != null) {
      return Image.network(FirebaseAuth.instance.currentUser!.photoURL!);
    } else {
      return const FaIcon(FontAwesomeIcons.user);
    }
  }
}
