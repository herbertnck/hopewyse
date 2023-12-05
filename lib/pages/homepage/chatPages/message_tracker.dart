import 'package:shared_preferences/shared_preferences.dart';

class MessageTracker {
  int _messageCount = 0; // No of messages sent by user
  DateTime? _lastMessageTime; //TIme of last message sent

  // SharedPreferences keys
  static const String _messageCountKey = 'message_count';
  static const String _lastMessageTimeKey = 'last_message_time';

  // Initialize the tracker
  MessageTracker() {
    _loadMessageCount();
    _loadLastMessageTime();
  }

  // Load messagecount from storage
  Future<void> _loadMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    _messageCount = prefs.getInt(_messageCountKey) ?? 0;
    print('message count from load $_messageCount');
  }

  // Load last message time from storage
  Future<void> _loadLastMessageTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeInMillis = prefs.getInt(_lastMessageTimeKey);
    if (timeInMillis != null) {
      _lastMessageTime = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    }
    print('Last message time loaded: $_lastMessageTime');
  }

  // save messagecount and last message time to storage
  Future<void> _saveMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_messageCountKey, _messageCount);
    print('message count saved is  $_messageCount');

    if (_lastMessageTime != null) {
      final timeInMillis = _lastMessageTime!.millisecondsSinceEpoch;
      await prefs.setInt(_lastMessageTimeKey, timeInMillis);
      print('Last message time saved: $_lastMessageTime');
    }
  }

  //Calculate remaining message count for the user
  int getRemainingMessageCount() {
    //Implement logic to reset message count if needed
    _resetMessageCountIfNecessary();
    print('remaining messagecount is : ${3 - _messageCount}');
    return 3 - _messageCount;
  }

  //INcrement message count when a message is sent
  void incrementMessageCount() {
    _messageCount++;
    _saveMessageCount(); // Save the updated message count
    //Update the last message time
    _lastMessageTime = DateTime.now();
  }

  // Check if the user has exceeded message limit
  bool isMessageLimitExceeded() {
    // returns true if the remaining count is less than or equal to 0.
    return getRemainingMessageCount() <= 0;
  }

  // Check if the message count needs to be reset. messages reset at 11.59 pm
  void _resetMessageCountIfNecessary() {
    print('_resetMessageCountIfNecessary');
    // print('Last message time: $_lastMessageTime');
    if (_lastMessageTime != null) {
      final currentTime = DateTime.now();
      final resetTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        23,
        59,
        0,
      );
      final timeDifference = currentTime.difference(_lastMessageTime!);
      print('Time difference is: $timeDifference');
      if (currentTime.isAfter(resetTime)) {
        _messageCount = 0;
        _lastMessageTime = null;
        _saveMessageCount();
      }
    } else {
      _messageCount = 0;
      _saveMessageCount();
    }
    print('Message count is now: $_messageCount');
  }
}
