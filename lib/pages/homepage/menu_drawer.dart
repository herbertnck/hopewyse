import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hopewyse/pages/authentication/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // Cached network image to save user profile image
    final cacheManager = DefaultCacheManager();

    return Drawer(
      child: Column(children: <Widget>[
        Center(
          child: UserAccountsDrawerHeader(
            // display user name
            accountName: Text(
              currentUser?.displayName ?? '',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 20),
            ),

            // display user email
            accountEmail: Text(
              currentUser?.email ?? '',
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 17),
            ),

            // display profile image
            // currentAccountPicture: ClipOval(
            //   child: CachedNetworkImage(
            //     imageUrl: currentUser?.photoURL ?? '',
            //     cacheManager: cacheManager,
            //     // use circle user icon as avater if the network connection
            //     errorWidget: (context, url, error) =>
            //         const FaIcon(FontAwesomeIcons.circleUser),
            //     placeholder: (context, url) =>
            //         const FaIcon(FontAwesomeIcons.circleUser),
            //   ),
            // ),

            currentAccountPicture: FutureBuilder<File>(
              future: DefaultCacheManager()
                  .getSingleFile(currentUser?.photoURL ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const FaIcon(FontAwesomeIcons.circleUser);
                } else if (snapshot.hasError) {
                  return const FaIcon(FontAwesomeIcons.circleUser);
                } else if (snapshot.hasData) {
                  return CircleAvatar(
                    backgroundImage: FileImage(snapshot.data!),
                  );
                } else {
                  return const CircleAvatar(); // Default avatar if no image available
                }
              },
            ),

            decoration: const BoxDecoration(
              color: Color.fromARGB(200, 58, 168, 193),
            ),
          ),
        ),

        // //Drawer List view
        // ListTile(
        //   leading: const Icon(Icons.settings),
        //   title: const Text(
        //     'Settings',
        //     style: TextStyle(
        //       fontSize: 20.0,
        //     ),
        //   ),
        //   onTap: () {
        //     Navigator.of(context)
        //         .push(MaterialPageRoute(builder: (context) => SettingsPage()));
        //   },
        // ),

        // const Divider(),
        const Expanded(child: SizedBox()),
        // Logout button
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onTap: () {
            AuthService().signOut();
          },
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
}
