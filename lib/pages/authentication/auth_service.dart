import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../homepage/home.dart';
import 'login_page.dart';

class AuthService {
  String folderPath = ""; // Declare folderPath

  // Determine if the user is authenticated.
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while the directory is being created
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any errors that occurred during directory creation
          return const Text('Error checking authentication state');
        } else {
          // Check if the user is authenticated
          if (FirebaseAuth.instance.currentUser != null) {
            return const Home();
          } else {
            // User is not authenticated, return LoginPage
            print('User not authenticated');
            return const LoginPage();
          }
        }
      },
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(scopes: <String>["email"]).signIn();
      // The user cancelled the sign-in process
      if (googleUser == null) {
        return;
      }
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // After successful login, navigate to the homepage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (error) {
      if (error is FirebaseAuthException) {
        print('Login failed: ${error.message}');
      } else {
        Fluttertoast.showToast(
          msg: 'An unexpected error occurred during login.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    }
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
