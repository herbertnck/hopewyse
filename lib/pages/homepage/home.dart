//provides navigation for home_page, cht_page and library_page
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'chat_page.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'chatscreen.dart';
import '../authentication/googleai.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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
      // appBar: AppBar()

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
          ChatPage(),
          // ChatScreen(),
          GenerativeAISample(),
          LibraryPage(path: ''),
        ],
      ),

      // Bottom navigation bar
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
            icon: Icon(Icons.chat_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '',
          ),
        ],
      ),
    );
  }
}
