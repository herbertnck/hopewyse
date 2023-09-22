import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hopewyse/pages/homepage1/library_books.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hopewyse/pages/homepage1/bookDetails.dart';
import 'package:hopewyse/pages/homepage1/menuDrawer.dart';
import 'homePage.dart';
import 'libraryPage.dart';

class Home extends StatefulWidget {
  final book;

  const Home({super.key, this.book});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  int pageIndex = 0;
  final translatorModelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(animationController);

    animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();

    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar innitialized
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(200, 58, 168, 193),
        // forceElevated: true,
        // floating: true,
        // pinned: true,
        // expandedHeight: 100,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const FaIcon(FontAwesomeIcons.circleUser),
          ),
        ),

        flexibleSpace: const FlexibleSpaceBar(
          title: Text(
            'HopeWyse',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      // End of AppBar

      // Books view
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomePage(),
          LibraryPage(
            path: '',
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '',
          ),
        ],
      ),

      // Drawer Innitialized
      drawer: const Drawer(child: MenuDrawer()),
    );
  }
}
