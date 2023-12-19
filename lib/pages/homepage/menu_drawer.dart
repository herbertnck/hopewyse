import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

import '../authentication/auth_service.dart';
import 'chatPages/reply_counter.dart';
import 'settings_page.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Authenticated user details
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // Create an instance of the ReplyCounter class
    final ReplyCounter replyCounter = ReplyCounter();
    // print('replies in menu drawer is ${replyCounter.getReplyCount()}');

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
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),

        // const Divider(),

        // Card to display number of points and rank
        PointsCard(replyCounter: replyCounter),

        const Expanded(child: SizedBox()),
        // Logout button
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          onTap: () {
            AuthService().signOut();
          },
        ),

        // send mail to hopewyse
        InkWell(
          onDoubleTap: () async {
            final mailtoLink = Mailto(
              to: ['hopewysecommunity@gmail.com'],
              subject: '',
            );
            await launch('$mailtoLink');
          },
          child: const ListTile(
            title: Text(
              'hopewysecommunity@gmail.com',
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                // color: Colors.blue,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class PointsCard extends StatelessWidget {
  final ReplyCounter replyCounter;

  const PointsCard({
    super.key,
    required this.replyCounter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: FutureBuilder<int>(
        future: replyCounter.getReplyCount(), // Use the future directly
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Or a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return ListTile(
              tileColor: Colors.greenAccent,
              title: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // color: Colors.blue,
                      color: Colors.orangeAccent,
                    ),
                    child: Center(
                      child: Text(
                        snapshot.data.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rank: ${replyCounter.determineRank()}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox(); // Adjust as needed
          }
        },
      ),
    );
  }
}
