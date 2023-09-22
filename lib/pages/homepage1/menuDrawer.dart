import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopewyse/pages/authentication/authService.dart';
// import 'package:hopewyse/pages/homepage/fileupload.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: <Widget>[
        Stack(children: <Widget>[
          Container(
              color: const Color.fromARGB(200, 58, 168, 193),
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const SizedBox(width: 6),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10),
                    //   child: Provider.of(context).auth.getProfileImage(),
                    // ),

                    // CircleAvatar(
                    //   radius: 40,
                    //   foregroundImage: AssetImage(
                    //       FirebaseAuth.instance.currentUser!.photoURL!),
                    //       //  icon: const FaIcon(FontAwesomeIcons.circleUser),

                    //   // Image.network(FirebaseAuth.instance.currentUser!.photoURL!)
                    //   // AuthService().getProfileImage()),
                    // ),

                    const SizedBox(height: 6),
                    // ClipOval(
                    //   //fit: BoxFit.cover,
                    //   child: Image(
                    //     image: AssetImage(
                    //         FirebaseAuth.instance.currentUser!.photoURL!),

                    //     // fit: BoxFit.cover,
                    //   ),
                    // ),

                    // Display user name
                    Text(
                      FirebaseAuth.instance.currentUser!.displayName!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    ),
                  ])),
          const SizedBox(height: 6),
        ]),

        //Drawer List view
        const ListTile(
          leading: Icon(Icons.settings),
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        ListTile(
          // leading: const FaIcon(FontAwesomeIcons.fileArrowUp),
          leading: const Icon(Icons.upload_file),
          title: const Text(
            "Upload",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onTap: () {
            // _navigateToFileUpload(context);
          },
        ),
        ListTile(
          // leading: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
          leading: const Icon(Icons.logout),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onTap: () {
            AuthService().signOut();
            //  _navigateToLoginPage(context);
          },
        ),
        const SizedBox(height: 150),
        const ListTile(
          title: Text(
            'Version 0.0.0',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        const ListTile(
          title: Text(
            'hopewysecommunity@gmail.com',
            style: TextStyle(
              fontSize: 15.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ]),
    );
  }

  // void _navigateToFileUpload(BuildContext context) {
  //   Navigator.push<void>(
  //     context,
  //     MaterialPageRoute<void>(
  //       builder: (BuildContext context) => const FileUpload(),
  //     ),
  //   );
  // }
}
