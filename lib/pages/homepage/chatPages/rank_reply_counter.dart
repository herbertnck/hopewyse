import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications.dart';

class ReplyCounter {
  late SharedPreferences _prefs;  // Initialize SharedPreferences instance
  int replyCount = 0;   // Initialize reply count variable
  // Define the key for storing and retrieving reply count from SharedPreferences
  static const String _replyCountKey = 'reply_count';
  bool _initialized = false;

  ReplyCounter() {
    _initializeSharedPreferences();
    // _loadReplyCount();
  }

  // Initialize SharedPreferences instance
  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    await loadReplyCount();
  }
  
  // Load reply count from SharedPreferences
  Future<void> loadReplyCount() async {
    replyCount = _prefs.getInt(_replyCountKey) ?? 0;
    print('Total replies loaded: $replyCount');
    // resetReplyCount();
  }

  // Save reply count to SharedPreferences
  Future<void> saveReplyCount(BuildContext context) async {
    await _prefs.setInt(_replyCountKey, replyCount);
    checkForNewRank(context);
  }

  // Get the current reply count
  Future<int> getReplyCount() async {
    if (!_initialized) {
      await _initializeSharedPreferences();
    }
    await loadReplyCount();
    print('replies from get reply count $replyCount');
    return replyCount;
  }

  // Increment reply count
  void incrementReplyCount(BuildContext context) {
    replyCount++;
    saveReplyCount(context); // Save the updated count to SharedPreferences
  }

  // // Reset reply count
  // void resetReplyCount() {
  //   replyCount = 0;
  //   saveReplyCount(); // Save the updated count to SharedPreferences
  // }

  // Function to determine the rank based on points
  String determineRank() {
    if (replyCount >= 540) {
      return "Eternal Sojourner"; // 20 Heavenly COnversationalist
    } else if (replyCount >= 490) {
      return "Ascended Sage"; // 19
    } else if (replyCount >= 445) {
      return "Radiant Beacon"; // 18
    } else if (replyCount >= 400) {
      return "Ascendant Visionary"; // 17 Pillar of Faith
    } else if (replyCount >= 360) {
      return "Prophet's Vessel"; // 16
    } else if (replyCount >= 320) {
      return "Ethereal Sage"; // 15
    } else if (replyCount >= 285) {
      return "Harmony Adept"; // 14
    } else if (replyCount >= 250) {
      return "Divine Communicant"; // 13 Divine Messenger, Celestial visionnary,
    } else if (replyCount >= 220) {
      return "Seraphic Devotee"; // 12
    } else if (replyCount >= 190) {
      return "Wisdom Illuminator"; // 11
    } else if (replyCount >= 160) {
      return "Heavenly Disciple"; // 10
    } else if (replyCount >= 135) {
      return "Celestial Scholar"; // 9
    } else if (replyCount >= 8) {
      //110
      return "Heavenly Seeker"; // 8
    } else if (replyCount >= 7) {
      //90
      return "Soulful Disciple"; // 7
    } else if (replyCount >= 6) {
      //70
      return "Enlightenment Follower"; // 6
    } else if (replyCount >= 5) {
      //50
      return "Wisdom Aspirant"; // 5
    } else if (replyCount >= 4) {
      //35
      return "Faithful Apprentice"; // 4
    } else if (replyCount >= 3) {
      //20
      return "Divine Inquirer"; // 3
    } else if (replyCount >= 2) {
      //10, 3
      return "Spiritual Explorer"; // 2
    } else {
      return "Seeker of Light"; // 1
    }
  }

  // Check for a new rank based on the current reply count
  Future<void> checkForNewRank(BuildContext context) async {
    if (!_initialized) {
      await _initializeSharedPreferences();
    }
    await loadReplyCount();

    // Define the threshold for each rank
    List<int> rankThresholds = [
      1, // Seeker of Light
      2, // Spiritual Explorer
      3, // Divine Inquirer
      4, // Faithful Apprentice
      5, // Wisdom Aspirant
      6, // Enlightenment Follower
      7, // Soulful Disciple
      8, // Heavenly Seeker
      135, // Celestial Scholar
      160, // Angelic Acolyte
      190, // Messenger's Disciple
      220, // Seraphic Devotee
      250, // Divine Communicant
      285, // Harmony Adept
      320, // Ethereal Sage
      360, // Prophet's Vessel
      400, // Ascendant Visionary
      445, // Radiant Illuminator
      490, // Transcendent Pilgrim
      540, // Eternal Sojourner
    ];

    for (int i = rankThresholds.length - 1; i >= 0; i--) {
      if (replyCount == rankThresholds[i]) {
        String currentRank = determineRank();
        print('Congratulations! You have achieved the rank of $currentRank.');

        // Show the rank notification
        NotificationService().showRankNotification(currentRank, context);

        break; // Exit the loop once the highest achieved rank is found
      }
    }
  }

  
}
