import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HopeWyse'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to HopeWyse',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "At HopeWyse, we believe that everyone's spiritual journey is unique and deeply personal. The app designed to support you every step of your spiritual journey. Whether you're a seasoned believer seeking deeper insights or a newcomer eager to explore the wonders of faith, HopeWyse is here to guide you on your path to spiritual growth.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "To empower individuals to cultivate a deeper connection with their spirituality and lead more fulfilling lives. Through technology and timeless wisdom, we aim to provide accessible, personalized guidance that resonates with people from all walks of life.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Text(
              'Get Started Today',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Whether you're seeking guidance, inspiration, or simply a sense of belonging, you'll find it all here at HopeWyse.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
