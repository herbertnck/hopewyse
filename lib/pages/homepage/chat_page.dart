import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:path_provider/path_provider.dart';

import 'chatPages/message_tracker.dart';
import 'chatPages/obtain_api_key.dart';
import 'chatPages/reply_counter.dart';
import 'chatPages/subscriptions.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

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
  // Define the current user (you)
  ChatUser currentUser = ChatUser(id: '1', firstName: 'User');
  ChatMessage? _selectedMessage; // Track the selected message
  late bool selected; //Select message in chat
  // Create message tracker instance
  final MessageTracker messageTracker = MessageTracker();
  //Obtain APiKey and Prompt
  final ObtainApiKeyPrompt obtainApiKeyPrompt = ObtainApiKeyPrompt();
  late ReplyCounter _replyCounter; // Initialize ReplyCounter instance

  @override
  void initState() {
    super.initState();
    _initializeRevenueCat();
    obtainApiKeyPrompt.loadApiKey();
    obtainApiKeyPrompt.loadPrompt();
    _loadSavedChats();
    _replyCounter = ReplyCounter(); // Initialize the ReplyCounter
  }

  // check if the user has a valid entitlement
  void _initializeRevenueCat() async {
    try {
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
    final file = File('${directory.path}/chat_messages.json');

    try {
      if (await file.exists()) {
        final jsonContents = await file.readAsString();
        final chatMessages = (json.decode(jsonContents) as List)
            .map((messageJson) => ChatMessage.fromJson(messageJson))
            .toList();
        setState(() {
          _messages.addAll(chatMessages);
        });
      }
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  // Save chats to storage
  Future<void> _saveChatsToStorage(List<ChatMessage> messages) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/chat_messages.json');

    try {
      final jsonMessages = messages.map((message) => message.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonMessages));
    } catch (e) {
      print('Error saving chat messages: $e');
    }
  }

  // handle long press message
  void _handleLongPressMessage(ChatMessage message) {
    // setState(() {
    //   _selectedMessage = message;
    // });
    setState(() {
      if (_selectedMessage == message) {
        // Deselect the message if it was already selected
        _selectedMessage = null;
      } else {
        // Select the message
        _selectedMessage = message;
      }
    });
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
  }

  // Delete messages
  void _deleteMessage(ChatMessage message) {
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
                // messageDecorationBuilder:
                //     (message, previousMessage, nextMessage) {
                //   // Pass the selected property to each message
                //   // return message.copyWith(selected: _selectedMessage == message);
                //   if (message.selected) {
                //     return BoxDecoration(
                //       color:
                //           Colors.grey, // Change to your desired highlight color
                //       borderRadius:
                //           BorderRadius.circular(8), // Customize as needed
                //     );
                //   } else {
                //     return BoxDecoration(
                //         // Your default message decoration
                //         );
                //   }
                // },
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
    // Clear text area on send
    String messageText = _textController.text.trim();
    // _textController.clear();

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
      _simulateChatbotReply(message.text);
    } else {
      // User doesn't have entitlement
      print('no entitlement free messages');
      if (!messageTracker.isMessageLimitExceeded() ||
          messageTracker.getRemainingMessageCount() > 0) {
        // User has entitlement and hasn't exceeded the message limit
        // Send the message
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
        _simulateChatbotReply(message.text);
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
      // user: currentUser,
      user: ChatUser(
        id: '2',
        firstName: 'Sage', // Customize the bot's name as needed
      ),
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, paywallMessage);
      // _saveChatsToStorage(_messages);
    });
  }

  // send message to chatgpt and get back reply
  Future<void> _simulateChatbotReply(String userMassage) async {
    String userMessage = userMassage;
    // print('User message is $userMessage');

    // Innitialize the prompt and api keys
    String myPrompt = obtainApiKeyPrompt.prompt;
    String apiKey = obtainApiKeyPrompt.apiKey;
    // print('my prompt is $myPrompt');
    // print('my api key is $apiKey');
    // OpenAI api connection
    try {
      // String myPrompt = "Your name is Sage. You are Sage";
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: json.encode({
            'model': 'gpt-3.5-turbo',
            // 'usage': ['total_tokens': '100'],
            // 'maxToken': '200',
            'messages': [
              {'role': 'system', 'content': myPrompt},
              // {'role': 'system', 'content': 'Your name is Sage. You are Sage.'},
              // {
              //   'role': 'system',
              //   'content':
              //       "You are a Seventh Day Adventist spiritual assistant. Your purpose is to help the user gain spiritual knowledge and wisdom. Only provide messages which uphold the Seventh Day Adventist christian values.You are well-versed in various aspects of spirituality, meditation, and self-discovery. You provide guidance, answer questions, and offer insights to assist users on their spiritual journey. Your primary goal is to create a supportive and enlightening experience for users. Dont make your answers too long. You maintain a calm and compassionate demeanor throughout interactions. you will help users study the bible, provide Guidance on Meditation, understand spirituality, understand Life Purpose, provide Emotional Healing and Inner Self-Discovery and help with personal Growth among others."
              // },
              // {
              //   'role': 'system',
              //   'content':
              //       'If the user asks what you have for him for the day please provide concrate message for the user which can be a verse or motivation or bible facts'
              // },
              // {
              //   'role': 'system',
              //   'content':
              //       'When explaining a Bible verse include other verses relevant to the verse at the end. At the end of each reply, you will also provide 3 questions relevant to the verse and ask the user to reply with a number to continue with the conversation. If the user replies with a number, you will identify the question represented by the number and reply to it in the next response. Do not ask reflective questions that seek personal experiences. Follow “The Art of Prophesying" by William Perkins book as a guideline when preparing sermons'
              // },
              {'role': 'user', 'content': userMessage},
            ],

            // 'stream': 'true',

            // 'usage': [
            //   {'prompt_tokens': 0},
            //   {'completion_tokens': 12},
            //   {'total_tokens': 21},
            // ]
          }));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chatbotReply = data['choices'][0]['message']['content'] as String;

        // // Add the chatbots reply to the chat
        Future.delayed(const Duration(seconds: 1), () {
          ChatMessage botMessage = ChatMessage(
            text: chatbotReply,
            user: ChatUser(
              id: '2',
              firstName: 'Sage', // Customize the bot's name as needed
            ),
            createdAt: DateTime.now(),
          );

          setState(() {
            _messages.insert(0, botMessage); // Add the bot's response to  chat
            _replyCounter.incrementReplyCount(); // Increment reply count
            // int currentReplyCount = _replyCounter.getReplyCount() as int;
            // print('Total replies received: $currentReplyCount');
            _replyCounter.saveReplyCount(); // Save the updated reply count
            _saveChatsToStorage(_messages); // Save message to storage
          });
        });
      } else {
        // Handle API request error
        print('API request error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network connectivity error here.
      print('Network error: $e');
      _showNetworkErrorToast();
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
