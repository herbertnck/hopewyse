import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

import 'chatPages/reset_message_tracker.dart';
import 'chatPages/obtain_apikey_prompt.dart';
import 'chatPages/rank_reply_counter.dart';
import 'chatPages/subscriptions.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();

  // Define a callback function to be called after a successful purchase
  void updateEntitlement() {
    _ChatPageState()._initializeRevenueCat();
  }
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = []; //List of chat messages
  // control the text in input field
  final TextEditingController _textController = TextEditingController();
  int minLines = 1;
  bool _hasEntitlement = false; // Keep track if user has subscription
  // Define users
  final currentUser = ChatUser(id: '1', firstName: 'User');
  final sageUser = ChatUser(id: '2', firstName: 'Sage');
  ChatMessage? _selectedMessage; // Track the selected message
  late bool selected; //Select message in chat
  // Create message tracker instance
  final MessageTracker messageTracker = MessageTracker();
  //Obtain APiKey and Prompt
  final ObtainApiKeyPrompt obtainApiKeyPrompt = ObtainApiKeyPrompt();
  late ReplyCounter _replyCounter; // Initialize ReplyCounter instance
  late String _selectedBibleType;
  List messageList = [];

  @override
  void initState() {
    super.initState();
    _initializeRevenueCat();
    // _integrateGeminiAPI(_messages);
    obtainApiKeyPrompt.loadApiKey();
    obtainApiKeyPrompt.loadPrompt();
    _loadSavedChats();
    _replyCounter = ReplyCounter(); // Initialize the ReplyCounter
    // _selectedBibleType = ''; // Initialize _selectedBibleType here
    _getSelectedBibleType();
  }

  // check if the user has a valid entitlement
  void _initializeRevenueCat() async {
    try {
      print('error initializeRevenueCat run');
      await RevenueCatManager.initializeRevenueCat();
      final hasEntitlement = await RevenueCatManager.checkEntitlement();

      setState(() {
        _hasEntitlement = hasEntitlement; // Update entitlement status
      });

      if (_hasEntitlement) {
        print('user has entitlement');
      } else {
        print('user has no entitlement');
      }
    } catch (e) {
      print('Error initializing revenuecat');
    }
  }

  //Load saved chats from storage
  Future<void> _loadSavedChats() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/messages.json');

    try {
      if (await file.exists()) {
        final jsonContents = await file.readAsString();
        final chatMessages = (json.decode(jsonContents) as List)
            .map((messageJson) => ChatMessage.fromJson(messageJson))
            .toList();

        setState(() {
          // _messages.clear(); // Clear existing messages before adding loaded ones
          _messages.addAll(chatMessages);
        });

        if (_messages.isEmpty) {
          _howToUseSage(); // Send initial message when chat is empty
        }
        print('messages loaded successfully');
      } else {
        _howToUseSage(); // Send initial message when chat is empty
        print('messages file doesnt exist');
      }
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  // Save chats to storage
  Future<void> _saveChatsToStorage(List messages) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/messages.json');

    try {
      final jsonMessages = messages.map((message) => message.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonMessages));
      // print('message saved successfully');
    } catch (e) {
      print('Error saving chat messages: $e');
    }
  }

  // Method to retrieve the selected Bible type
  Future<void> _getSelectedBibleType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBibleType = prefs.getString('selectedBibleType') ?? 'Default';
    });
  }

  // Function to display how to use Sage bot
  void _howToUseSage() {
    // Split the message text into paragraphs
    String messageText =
        "Welcome to Sage your Bible Companion! I'm your faithful guide on this spiritual journey.\nHere's how I can assist you:\n1. Explain a Bible Verse: Simply send a verse and I'll provide insights and explanations.\n2. Prepare a Sermon: Share your theme and I'll offer suggestions and relevant passages. You can include how long the sermon should be.\n3. Compare Two Verses: Wondering about the differences between two verses? Let me know and I'll break it down for you.\n4. Spiritual Advice: Seeking guidance? Share your concerns and I'll offer spiritual advice and wisdom.\n5. Prepare Family Prayers: I can help craft a heartfelt and meaningful prayer for your loved ones.\nTo get started, type your question or request and let's embark on this enlightening journey together!";
    // Create a single message with the combined text
    ChatMessage howToUseSage = ChatMessage(
      text: messageText,
      user: sageUser,
      createdAt: DateTime.now(),
    );
    // Insert messages into the chat
    setState(() {
      _messages.insert(0, howToUseSage);
      _saveChatsToStorage(_messages);
    });
  }

  // handle long press message
  void _handleLongPressMessage(ChatMessage message) {
    setState(() {
      if (_selectedMessage == message) {
        // Deselect the message if it was already selected
        _selectedMessage = null;
      } else {
        // Select the message
        _selectedMessage = message;
      }
    });
    // final RenderBox overlay =
    //     Overlay.of(context)!.context.findRenderObject() as RenderBox;
  }

  // Delete messages
  void _deleteMessage(message) {
    setState(() {
      _messages.remove(message);
    });
    _saveChatsToStorage(_messages);
  }

  // Handle menu item selected
  void _handleMenuItemSelected(String value) {
    if (_selectedMessage != null) {
      switch (value) {
        case 'share':
          // Handle share action
          // Implement the share logic here
          break;
        case 'delete':
          // Handle delete action
          _deleteMessage(_selectedMessage!);
          break;
        case 'copy':
          // Handle copy action
          Clipboard.setData(ClipboardData(text: _selectedMessage!.text));
          break;
      }
      setState(() {
        _selectedMessage = null; // Clear the selected message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Chat with Sage')),
        backgroundColor: const Color.fromARGB(200, 58, 168, 193),
        actions: _selectedMessage != null
            ? [
                PopupMenuButton<String>(
                  onSelected: _handleMenuItemSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          // Icon(Icons.share),
                          // SizedBox(width: 8), // Add some spacing
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          // Icon(Icons.delete),
                          // SizedBox(width: 8), // Add some spacing
                          Text('Delete'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'copy',
                      child: Row(
                        children: [
                          // Icon(Icons.content_copy),
                          // SizedBox(width: 8), // Add some spacing
                          Text('Copy'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null, // Hide the menu when no message is selected
      ),
      body: Column(
        children: [
          // Chat messages display using DashChat
          Expanded(
            child: DashChat(
              currentUser: currentUser,
              onSend: _handleSubmitted,
              messages: _messages,
              messageOptions: MessageOptions(
                onLongPressMessage: _handleLongPressMessage,
              ),
              // messageListOptions: MessageListOptions(),
            ),
          ),
        ],
      ),
    );
  }

  // Handle sent message
  void _handleSubmitted(ChatMessage message) {
    String messageText = _textController.text.trim(); // Trim extra spaces
    // _textController.clear(); //Clear text area on send

    if (_hasEntitlement) {
      // _showUpsellScreen();
      // User has entitlement, send the message
      print('dont show upsell screen');
      if (messageText.isNotEmpty) {
        ChatMessage message = ChatMessage(
          text: messageText,
          user: currentUser,
          createdAt: DateTime.now(),
        );
        _textController.clear();
      }
      setState(() {
        _messages.insert(0, message); // Add the sent message to the chat
        // Save the chat messages to the device storage
        _saveChatsToStorage(_messages);
      });
      // Call _simulateChatbotReply with the user's message.
      // _simulateChatbotReply(message.text);
      _integrateGeminiAPI(message.text);
    } else {
      // User doesn't have entitlement
      print('no entitlement free messages');
      if (!messageTracker.isMessageLimitExceeded() ||
          messageTracker.getRemainingMessageCount() > 0) {
        // User has entitlement and hasn't exceeded the message limit
        // Send the message
        String messageText = _textController.text.trim();
        if (messageText.isNotEmpty) {
          ChatMessage message = ChatMessage(
            text: messageText,
            user: currentUser,
            createdAt: DateTime.now(),
          );
          _textController.clear();
        }
        setState(() {
          _messages.insert(0, message); // Add the sent message to the chat
          // Save the chat messages to the device storage
          _saveChatsToStorage(_messages);
        });
        // Call _simulateChatbotReply with the user's message.
        // _simulateChatbotReply(message.text);
        _integrateGeminiAPI(message.text);
        // print('res2 message: ${message.text}');
        //Increment message count
        messageTracker.incrementMessageCount();
      } else {
        //  message limit is exceeded
        print('no free messages show upsell screen');
        _showPaywall();
        _textController.clear();
        _showUpsellScreen();
      }
    }
  }

  // Function to show the paywall
  void _showPaywall() {
    // Display the paywall and send a message to the chatbot
    ChatMessage paywallMessage = ChatMessage(
      text: 'Please upgrade to continue your session with Sage',
      user: sageUser,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, paywallMessage);
      // _saveChatsToStorage(_messages);
    });
  }

  // // send message to chatgpt and get back reply
  //   // Innitialize the prompt and api keys
  //   String myPrompt = obtainApiKeyPrompt.prompt;
  //   String apiKey = obtainApiKeyPrompt.apiKey;
  //   print('Selected bible type is $_selectedBibleType');
  //   // print('my prompt is $myPrompt');
  //   // print('my api key is $apiKey');
  //   // OpenAI api connection
  //   try {
  //     // String myPrompt = "Your name is Sage. You are Sage";
  //     final response = await http.post(
  //         Uri.parse('https://api.openai.com/v1/chat/completions'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $apiKey',
  //         },
  //         body: json.encode({
  //           'model': 'gpt-3.5-turbo',
  //           // 'usage': ['total_tokens': '100'],
  //           // 'maxToken': '200',
  //           'messages': [
  //             {'role': 'system', 'content': myPrompt},
  //             {
  //               'role': 'system',
  //               'content': 'use $_selectedBibleType for your reply'
  //             },
  //             // {'role': 'system', 'content': 'Your name is Sage. You are Sage.'},
  //             // {
  //             //   'role': 'system',
  //             //   'content':
  //             //       "You are a Seventh Day Adventist spiritual assistant. Your purpose is to help the user gain spiritual knowledge and wisdom. Only provide messages which uphold the Seventh Day Adventist christian values.You are well-versed in various aspects of spirituality, meditation, and self-discovery. You provide guidance, answer questions, and offer insights to assist users on their spiritual journey. Your primary goal is to create a supportive and enlightening experience for users. Dont make your answers too long. You maintain a calm and compassionate demeanor throughout interactions. you will help users study the bible, provide Guidance on Meditation, understand spirituality, understand Life Purpose, provide Emotional Healing and Inner Self-Discovery and help with personal Growth among others."
  //             // },
  //             // {
  //             //   'role': 'system',
  //             //   'content':
  //             //       'If the user asks what you have for him for the day please provide concrate message for the user which can be a verse or motivation or bible facts'
  //             // },
  //             // {
  //             //   'role': 'system',
  //             //   'content':
  //             //       'When explaining a Bible verse include other verses relevant to the verse at the end. At the end of each reply, you will also provide 3 questions relevant to the verse and ask the user to reply with a number to continue with the conversation. If the user replies with a number, you will identify the question represented by the number and reply to it in the next response. Do not ask reflective questions that seek personal experiences. Follow “The Art of Prophesying" by William Perkins book as a guideline when preparing sermons'
  //             // },
  //             {'role': 'user', 'content': userMessage},
  //           ],
  //         }));
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final chatbotReply = data['choices'][0]['message']['content'] as String;
  // }

  //Method to integrate Gemini API
  Future<void> _integrateGeminiAPI(String userMessage) async {
    print('res messages is $userMessage');

    try {
      // Innitialize the prompt and api keys
      String myPrompt = obtainApiKeyPrompt.prompt;
      String apiKey1 = obtainApiKeyPrompt.apiKey;
      // print('apikey1 is $apiKey1');
      if (apiKey1 == null) {
        print('No \$API_KEY1 variable');
        return;
      }

      // Initialize the Generative Model with the gemini-pro model
      // final model = GenerativeModel(
      //   // model: 'gemini-pro',
      //   model: 'gemini-1.5-flash-latest',
      //   apiKey: apiKey1,
      //   // generationConfig: GenerationConfig(maxOutputTokens: 100)
      // ); 
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system("$myPrompt and use $_selectedBibleType for your reply"),
        );

      // Start the chat with the initial prompt
      final chat = model.startChat();
      // print('message sent $chat');
      // final prompt = Content.text("$myPrompt and use $_selectedBibleType for your reply");
      final prompt = Content.text("Start chat with Sage");


      // Receive bot message  from the API
      final botResponse = await chat.sendMessage(prompt);
      print('Bot response is: ${botResponse.text}');

      // Check if the bot response is null
      // if (botResponse == null || botResponse.text == null) {
      //   print('No response received from Gemini API');
      //   return;
      // }

      // // Retry logic for null responses
      // int retries = 0;
      // while (botResponse == null || botResponse.text == null) {
      //   // Retry for a certain number of attempts
      //   if (retries >= 3) {
      //     print('Maximum retries reached, no response received');
      //     return;
      //   }

      //   // Wait for a short duration before retrying
      //   await Future.delayed(const Duration(seconds: 1));

      //   // Retry the API call
      //   // botResponse = await chat.sendMessage(content);

      //   retries++;
      // }

      // Add the Gemini API response to the chat
      // if (botResponse.text != null) {
      setState(() {
        try{
        ChatMessage botMessage = ChatMessage(
          text: botResponse.text ?? '',
          // text: botResponse.text,
          user: sageUser,
          createdAt: DateTime.now(),
        );
        _messages.insert(0, botMessage); // Add the bot's response to  chat
        _replyCounter.incrementReplyCount(context); // Increment reply count
        // int currentReplyCount = _replyCounter.getReplyCount() as int;
        // print('Total replies received: $currentReplyCount');
        _replyCounter.saveReplyCount(context); // Save the updated reply count
        _saveChatsToStorage(_messages); // Save message to storage
        } catch (e) {
        print('message parsing Error: $e');
      }});
      // } else {
      //   // Handle null response from the API
      //   print('No response received from Gemini API');
      // }

      // Handle no network connection
    } catch (e) {
      // print('Error: Network connection failed.');
      print('Error: $e');
    }
  }

  // Show network error toast
  void _showNetworkErrorToast() {
    Fluttertoast.showToast(
      msg: "Connection error",
      backgroundColor: Colors.black,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // Dispose text input after pressing send button
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Show the upsell screen in a bottom sheet
  void _showUpsellScreen() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return UpsellScreen(
          onPurchaseSuccess: () {
            _initializeRevenueCat(); // update entitlement
          },
        );
      },
    );
  }
}
