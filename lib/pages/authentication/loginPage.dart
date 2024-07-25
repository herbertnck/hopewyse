import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  final bool isSigningIn = false;

  Future<void> checkInternetAndSignIn(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return;
    }

    AuthService().signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(
          left: 1,
          right: 1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text("Welcome To",
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
            const SizedBox(
              height: 15,
            ),
            const Text("Hope Wyse",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Color.fromARGB(250, 58, 168, 193),
                )),
            const SizedBox(
              height: 11,
            ),
            Image.asset('assets/images/HopeWyseCanvas.png'),
            const SizedBox(height: 40),
            GestureDetector(
              child: OutlinedButton.icon(
                  //borderSide: const BorderSide(color: Colors.black),
                  label: const Text(
                    'Sign In With Google',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  //style: const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                  icon: const FaIcon(
                    FontAwesomeIcons.google,

                    // color: Colors.orangeAccent,
                  ),
                  onPressed: () {
                    checkInternetAndSignIn(context);
                  }),
            )
          ],
        ),
      ),
    );
  }
}
