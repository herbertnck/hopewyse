import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hopewyse/pages/authentication/authService.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  // To Be Implemented: No internet connection error.

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(200, 58, 168, 193),
      ),
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
            const Text("Welcome Back To ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
            const SizedBox(
              height: 15,
            ),
            const Text("HopeWyse",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Color.fromARGB(250, 58, 168, 193),
                )),
            const SizedBox(
              height: 50,
            ),
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
                  AuthService().signInWithGoogle();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
