import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatview/chatview.dart';
import 'chatPages/models/theme.dart';

import 'chatPages/reset_message_tracker.dart';
import 'chatPages/obtain_api_key.dart';
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
  // final List<ChatMessage> _messages = []; //List of chat messages
  // control the text in input field
  final TextEditingController _textController = TextEditingController();
  int minLines = 1;
  bool _hasEntitlement = false; // Keep track if user has subscription
  // Define the current user (you)
  final currentUser = ChatUser(id: '1', name: 'User');
  final sageUser = ChatUser(id: '2', name: 'Sage');
  // ChatMessage? _selectedMessage; // Track the selected message
  late bool selected; //Select message in chat
  // Create message tracker instance
  final MessageTracker messageTracker = MessageTracker();
  //Obtain APiKey and Prompt
  final ObtainApiKeyPrompt obtainApiKeyPrompt = ObtainApiKeyPrompt();
  late ReplyCounter _replyCounter; // Initialize ReplyCounter instance
  late String _selectedBibleType;

  // late ChatController _chatController;
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  List<Message> messageList = [
    Message(
      id: '1',
      message: "Hi",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '2',
      message: "Hello",
      createdAt: DateTime.now(),
      sendBy: '2',
    ),
  ];
  late final _chatController;

  @override
  void initState() {
    super.initState();
    _initializeRevenueCat();
    obtainApiKeyPrompt.loadApiKey();
    obtainApiKeyPrompt.loadPrompt();
    // _loadSavedChats();
    _replyCounter = ReplyCounter(); // Initialize the ReplyCounter
    // _selectedBibleType = ''; // Initialize _selectedBibleType here
    _getSelectedBibleType();

    messageList = []; // Initialize messageList here
    _chatController = ChatController(
      // initialMessageList: _messages, // _messages is the list of ChatMessages
      initialMessageList: messageList, // _messages is the list of ChatMessages
      scrollController: ScrollController(),
      chatUsers: [
        ChatUser(
          id: '2',
          name: 'Sage',
          // profilePhoto: Data.profileImage,
        ),
      ], // List of ChatUsers
    );

    // if (_messages.isEmpty) {
    //   // Send initial message when chat is empty
    //   _simulateChatbotReply("How to use Sage chat");
    // }
  }

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
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

  // //Load saved chats from storage
  // Future<void> _loadSavedChats() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/chat_messages.json');

  //   try {
  //     if (await file.exists()) {
  //       final jsonContents = await file.readAsString();
  //       final chatMessages = (json.decode(jsonContents) as List)
  //           .map((messageJson) => ChatMessage.fromJson(messageJson))
  //           .toList();
  //       setState(() {
  //         _messages.addAll(chatMessages);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading chat messages: $e');
  //   }
  // }

  // Save chats to storage
  Future<void> _saveChatsToStorage(List messages) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/chat_messages.json');

    try {
      // await file.writeAsString(''); // Clear previous messages

      // final jsonMessages = messages.map((message) => message.toJson()).toList();
      // await file.writeAsString(jsonEncode(jsonMessages));
      final List jsonMessages = messages.map((message) {
        return message.toJson();
      }).toList();

      // Convert DateTime objects to ISO 8601 strings
      for (var jsonMessage in jsonMessages) {
        if (jsonMessage['createdAt'] is DateTime) {
          jsonMessage['createdAt'] =
              (jsonMessage['createdAt'] as DateTime).toIso8601String();
        }
      }
      await file.writeAsString(jsonEncode(jsonMessages));
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

  // // handle long press message
  // void _handleLongPressMessage( message) {
  //   // setState(() {
  //   //   _selectedMessage = message;
  //   // });
  //   setState(() {
  //     if (_selectedMessage == message) {
  //       // Deselect the message if it was already selected
  //       _selectedMessage = null;
  //     } else {
  //       // Select the message
  //       _selectedMessage = message;
  //     }
  //   });
  //   final RenderBox overlay =
  //       Overlay.of(context)!.context.findRenderObject() as RenderBox;
  // }

  // // Delete messages
  // void _deleteMessage( message) {
  //   setState(() {
  //     _messages.remove(message);
  //   });
  //   _saveChatsToStorage(_messages);
  // }

  // // Handle menu item selected
  // void _handleMenuItemSelected(String value) {
  //   if (_selectedMessage != null) {
  //     switch (value) {
  //       case 'share':
  //         // Handle share action
  //         // Implement the share logic here
  //         break;
  //       case 'delete':
  //         // Handle delete action
  //         _deleteMessage(_selectedMessage!);
  //         break;
  //       case 'copy':
  //         // Handle copy action
  //         Clipboard.setData(ClipboardData(text: _selectedMessage!.text));
  //         break;
  //     }
  //     setState(() {
  //       _selectedMessage = null; // Clear the selected message
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Chat with Sage',
          style: TextStyle(
            // color: theme.appBarTitleTextStyle,
            fontWeight: FontWeight.bold,
            fontSize: 19,
            letterSpacing: 0.25,
          ),
        )),
        backgroundColor: const Color.fromARGB(200, 58, 168, 193),
        // actions: _selectedMessage != null
        // ? [
        //     PopupMenuButton<String>(
        //       onSelected: _handleMenuItemSelected,
        //       itemBuilder: (context) => [
        //         const PopupMenuItem<String>(
        //           value: 'share',
        //           child: Row(
        //             children: [
        //               // Icon(Icons.share),
        //               // SizedBox(width: 8), // Add some spacing
        //               Text('Share'),
        //             ],
        //           ),
        //         ),
        //         const PopupMenuItem<String>(
        //           value: 'delete',
        //           child: Row(
        //             children: [
        //               // Icon(Icons.delete),
        //               // SizedBox(width: 8), // Add some spacing
        //               Text('Delete'),
        //             ],
        //           ),
        //         ),
        //         const PopupMenuItem<String>(
        //           value: 'copy',
        //           child: Row(
        //             children: [
        //               // Icon(Icons.content_copy),
        //               // SizedBox(width: 8), // Add some spacing
        //               Text('Copy'),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ]
        // : null, // Hide the menu when no message is selected
      ),
      body: Column(
        children: [
          // Chat messages display using DashChat
          Expanded(
            child:
                // DashChat(
                //   currentUser: currentUser,
                //   onSend: _handleSubmitted,
                //   messages: _messages,
                //   messageOptions: MessageOptions(
                //     onLongPressMessage: _handleLongPressMessage,
                //   ),
                //   // messageListOptions: MessageListOptions(),
                // ),
                ChatView(
              currentUser: currentUser,
              chatController: _chatController,
              onSendTap: _onSendTap,
              featureActiveConfig: const FeatureActiveConfig(
                lastSeenAgoBuilderVisibility: true,
                receiptsBuilderVisibility: true,
              ),
              chatViewState: ChatViewState.hasMessages,
              chatViewStateConfig: ChatViewStateConfiguration(
                loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                  loadingIndicatorColor: theme.outgoingChatBubbleColor,
                ),
                onReloadButtonTap: () {},
              ),
              typeIndicatorConfig: TypeIndicatorConfiguration(
                flashingCircleBrightColor: theme.flashingCircleBrightColor,
                flashingCircleDarkColor: theme.flashingCircleDarkColor,
              ),
              // appBar: ChatViewAppBar(
              //   elevation: theme.elevation,
              //   // backGroundColor: theme.appBarColor,
              //   backGroundColor: const Color.fromARGB(200, 58, 168, 193),
              //   // profilePicture: Data.profileImage,
              //   // backArrowColor: theme.backArrowColor,
              //   chatTitle: "Chat with Sage",
              //   chatTitleTextStyle: TextStyle(
              //     color: theme.appBarTitleTextStyle,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 19,
              //     letterSpacing: 0.25,
              //   ),
              //   // userStatus: "online",
              //   // userStatusTextStyle: const TextStyle(color: Colors.grey),
              //   // actions: [
              //   //   IconButton(
              //   //     // onPressed: _onThemeIconTap,
              //   //     onPressed: (() {}),
              //   //     icon: Icon(
              //   //       isDarkTheme
              //   //           ? Icons.brightness_4_outlined
              //   //           : Icons.dark_mode_outlined,
              //   //       color: theme.themeIconColor,
              //   //     ),
              //   //   ),
              //   //   IconButton(
              //   //     tooltip: 'Toggle TypingIndicator',
              //   //     onPressed: _showHideTypingIndicator,
              //   //     icon: Icon(
              //   //       Icons.keyboard,
              //   //       color: theme.themeIconColor,
              //   //     ),
              //   //   ),
              //   // ],
              // ),
              chatBackgroundConfig: ChatBackgroundConfiguration(
                messageTimeIconColor: theme.messageTimeIconColor,
                messageTimeTextStyle:
                    TextStyle(color: theme.messageTimeTextColor),
                defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
                  textStyle: TextStyle(
                    color: theme.chatHeaderColor,
                    fontSize: 17,
                  ),
                ),
                backgroundColor: theme.backgroundColor,
              ),
              sendMessageConfig: SendMessageConfiguration(
                imagePickerIconsConfig: ImagePickerIconsConfiguration(
                  cameraIconColor: theme.cameraIconColor,
                  galleryIconColor: theme.galleryIconColor,
                ),
                replyMessageColor: theme.replyMessageColor,
                defaultSendButtonColor: theme.sendButtonColor,
                replyDialogColor: theme.replyDialogColor,
                replyTitleColor: theme.replyTitleColor,
                textFieldBackgroundColor: theme.textFieldBackgroundColor,
                closeIconColor: theme.closeIconColor,
                textFieldConfig: TextFieldConfiguration(
                  onMessageTyping: (status) {
                    /// Do with status
                    debugPrint(status.toString());
                  },
                  compositionThresholdTime: const Duration(seconds: 1),
                  textStyle: TextStyle(color: theme.textFieldTextColor),
                ),
                micIconColor: theme.replyMicIconColor,
                voiceRecordingConfiguration: VoiceRecordingConfiguration(
                  backgroundColor: theme.waveformBackgroundColor,
                  recorderIconColor: theme.recordIconColor,
                  waveStyle: WaveStyle(
                    showMiddleLine: false,
                    waveColor: theme.waveColor ?? Colors.white,
                    extendWaveform: true,
                  ),
                ),
              ),
              chatBubbleConfig: ChatBubbleConfiguration(
                // Sender's message chat bubble
                outgoingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(
                    backgroundColor: theme.linkPreviewOutgoingChatColor,
                    bodyStyle: theme.outgoingChatLinkBodyStyle,
                    titleStyle: theme.outgoingChatLinkTitleStyle,
                  ),
                  receiptsWidgetConfig: const ReceiptsWidgetConfig(
                      showReceiptsIn: ShowReceiptsIn.all),
                  color: theme.outgoingChatBubbleColor,
                ),
                // Receiver's message chat bubble
                inComingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(
                    linkStyle: TextStyle(
                      color: theme.inComingChatBubbleTextColor,
                      decoration: TextDecoration.underline,
                    ),
                    backgroundColor: theme.linkPreviewIncomingChatColor,
                    bodyStyle: theme.incomingChatLinkBodyStyle,
                    titleStyle: theme.incomingChatLinkTitleStyle,
                  ),
                  textStyle:
                      TextStyle(color: theme.inComingChatBubbleTextColor),
                  onMessageRead: (message) {
                    /// send your message reciepts to the other client
                    debugPrint('Message Read');
                  },
                  senderNameTextStyle:
                      TextStyle(color: theme.inComingChatBubbleTextColor),
                  color: theme.inComingChatBubbleColor,
                ),
              ),
              replyPopupConfig: ReplyPopupConfiguration(
                  backgroundColor: theme.replyPopupColor,
                  buttonTextStyle:
                      TextStyle(color: theme.replyPopupButtonColor),
                  topBorderColor: theme.replyPopupTopBorderColor,
                  onUnsendTap: (message) {
                    // message is 'Message' class instance
                    // Your code goes here
                  },
                  onReplyTap: (message) {
                    // message is 'Message' class instance
                    // Your code goes here
                  },
                  onReportTap: () {
                    // Your code goes here
                  },
                  onMoreTap: () {
                    // Your code goes here
                  }),
              reactionPopupConfig: ReactionPopupConfiguration(
                shadow: BoxShadow(
                  color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
                  blurRadius: 20,
                ),
                backgroundColor: theme.reactionPopupColor,
              ),
              messageConfig: MessageConfiguration(
                messageReactionConfig: MessageReactionConfiguration(
                  backgroundColor: theme.messageReactionBackGroundColor,
                  borderColor: theme.messageReactionBackGroundColor,
                  reactedUserCountTextStyle:
                      TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionCountTextStyle:
                      TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                    backgroundColor: theme.backgroundColor,
                    reactedUserTextStyle: TextStyle(
                      color: theme.inComingChatBubbleTextColor,
                    ),
                    reactionWidgetDecoration: BoxDecoration(
                      color: theme.inComingChatBubbleColor,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkTheme
                              ? Colors.black12
                              : Colors.grey.shade200,
                          offset: const Offset(0, 20),
                          blurRadius: 40,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                imageMessageConfig: ImageMessageConfiguration(
                  // onTap: () {},
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  shareIconConfig: ShareIconConfiguration(
                      defaultIconBackgroundColor:
                          theme.shareIconBackgroundColor,
                      defaultIconColor: theme.shareIconColor,
                      onPressed: ((p0) {
                        // Your code goes here
                      })),
                ),
              ),
              profileCircleConfig: const ProfileCircleConfiguration(
                  // profileImageUrl: Data.profileImage,
                  ),
              repliedMessageConfig: RepliedMessageConfiguration(
                backgroundColor: theme.repliedMessageColor,
                verticalBarColor: theme.verticalBarColor,
                repliedMsgAutoScrollConfig: const RepliedMsgAutoScrollConfig(
                  enableHighlightRepliedMsg: true,
                  highlightColor: Color.fromARGB(255, 128, 168, 255),
                  highlightScale: 1.1,
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.25,
                ),
                replyTitleTextStyle:
                    TextStyle(color: theme.repliedTitleTextColor),
              ),
              swipeToReplyConfig: SwipeToReplyConfiguration(
                replyIconColor: theme.swipeToReplyIconColor,
                onLeftSwipe: (message, sendBy) {
                  // Your code goes here
                },
                onRightSwipe: (message, sendBy) {
                  // Your code goes here
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSendTap(
    String message, // Text message to be sent
    ReplyMessage
        replyMessage, // Information about a message to which the current message is a reply
    MessageType messageType, // Type of message e.g text, image, audio
  ) {
    if (_hasEntitlement) {
      // User has entitlement, send the message
      print('dont show upsell screen');

      // final id = int.parse(messageList.last.id) + 1;   // Message id
      // _chatController.addMessage(
      //   Message(
      //     // id: id.toString(),
      //     createdAt: DateTime.now(),
      //     message: message,
      //     sendBy: currentUser.id,
      //     replyMessage: replyMessage,
      //     messageType: messageType,
      //   ),
      // );
      final newMessage = Message(
        // id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      );
      _chatController.addMessage(newMessage);
      _simulateChatbotReply(message);
    } else {
      // User doesn't have entitlement
      print('no entitlement free messages');
      if (!messageTracker.isMessageLimitExceeded() ||
          messageTracker.getRemainingMessageCount() > 0) {
        // User has entitlement and hasn't exceeded the message limit
        // Send the message
        final newMessage = Message(
          // id: id.toString(),
          createdAt: DateTime.now(),
          message: message,
          sendBy: currentUser.id,
          replyMessage: replyMessage,
          messageType: messageType,
        );
        _chatController.addMessage(newMessage);

        // setState(() {
        //   // _messages.insert(0, message); // Add the sent message to the chat
        //   // Save the chat messages to the device storage
        //   _saveChatsToStorage(_messages);
        // });
        // Call _simulateChatbotReply with the user's message.
        _simulateChatbotReply(message);
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
    // // Setting Initial Message Status to Undelivered
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _chatController.initialMessageList.last.setStatus =
    //       MessageStatus.undelivered;
    // });
    // // Setting Initial Message Status to Read
    // Future.delayed(const Duration(seconds: 1), () {
    //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    // });
  }

  // void _onSendTap(
  //     String message, ReplyMessage replyMessage, MessageType messageType) {
  //   final message = Message(
  //     id: '2',
  //     message: "How are you",
  //     createdAt: DateTime.now(),
  //     sendBy: currentUser.id,
  //     replyMessage: replyMessage,
  //     messageType: messageType,
  //   );
  //   _chatController.addMessage(message);
  // }

  // Handle sent message
  // void _handleSubmitted(ChatMessage message) {
  //   // Clear text area on send
  //   String messageText = _textController.text.trim();
  //   // _textController.clear();

  //   if (_hasEntitlement) {
  //     // _showUpsellScreen();
  //     // User has entitlement, send the message
  //     print('dont show upsell screen');
  //     if (messageText.isNotEmpty) {
  //       ChatMessage message = ChatMessage(
  //         text: messageText,
  //         user: currentUser,
  //         createdAt: DateTime.now(),
  //       );
  //       _textController.clear();
  //     }
  //     setState(() {
  //       _messages.insert(0, message); // Add the sent message to the chat
  //       // Save the chat messages to the device storage
  //       _saveChatsToStorage(_messages);
  //     });
  //     // Call _simulateChatbotReply with the user's message.
  //     _simulateChatbotReply(message.text);
  //   } else {
  //     // User doesn't have entitlement
  //     print('no entitlement free messages');
  //     if (!messageTracker.isMessageLimitExceeded() ||
  //         messageTracker.getRemainingMessageCount() > 0) {
  //       // User has entitlement and hasn't exceeded the message limit
  //       // Send the message
  //       if (messageText.isNotEmpty) {
  //         ChatMessage message = ChatMessage(
  //           text: messageText,
  //           user: currentUser,
  //           createdAt: DateTime.now(),
  //         );
  //         _textController.clear();
  //       }
  //       setState(() {
  //         _messages.insert(0, message); // Add the sent message to the chat
  //         // Save the chat messages to the device storage
  //         _saveChatsToStorage(_messages);
  //       });
  //       // Call _simulateChatbotReply with the user's message.
  //       _simulateChatbotReply(message.text);
  //       //Increment message count
  //       messageTracker.incrementMessageCount();
  //     } else {
  //       //  message limit is exceeded
  //       print('no free messages show upsell screen');
  //       _showPaywall();
  //       _textController.clear();
  //       _showUpsellScreen();
  //     }
  //   }
  // }

  // Function to show the paywall
  void _showPaywall() {
    // Display the paywall and send a message to the chatbot
    ChatMessage paywallMessage = ChatMessage(
      text: 'Please upgrade to continue your session with Sage',
      // user: currentUser,
      user: ChatUser(
        id: '2',
        name: 'Sage', // Customize the bot's name as needed
      ),
      createdAt: DateTime.now(),
    );

    // setState(() {
    //   _messages.insert(0, paywallMessage);
    //   // _saveChatsToStorage(_messages);
    // });
  }

  // send message to chatgpt and get back reply
  // Response code Error 400 means error in the chat gpt configuration
  Future<void> _simulateChatbotReply(String userMassage) async {
    String userMessage = userMassage;
    // print('User message is $userMessage');

    // Innitialize the prompt and api keys
    String myPrompt = obtainApiKeyPrompt.prompt;
    String apiKey = obtainApiKeyPrompt.apiKey;
    print('Selected bible type is $_selectedBibleType');
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
              {
                'role': 'system',
                'content': 'use $_selectedBibleType for your reply'
              },
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

            // 'stream': 'false',

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
          // ChatMessage botMessage = ChatMessage(
          //   text: chatbotReply,
          //   user: ChatUser(
          //     id: '2',
          //     name: 'Sage', // Customize the bot's name as needed
          //   ),
          //   createdAt: DateTime.now(),
          // );

          final botMessage = Message(
            message: chatbotReply,
            sendBy: sageUser.id,
            createdAt: DateTime.now(),
            // messageType: messageType,
          );

          setState(() {
            // _messages.insert(0, botMessage); // Add the bot's response to  chat
            _chatController.addMessage(botMessage);
            _chatController.initialMessageList.last.setStatus =
                MessageStatus.read;
            _replyCounter.incrementReplyCount(); // Increment reply count
            // int currentReplyCount = _replyCounter.getReplyCount() as int;
            // print('Total replies received: $currentReplyCount');
            _replyCounter.saveReplyCount(); // Save the updated reply count
            // _saveChatsToStorage(_messages); // Save message to storage
            _saveChatsToStorage(_chatController.initialMessageList);
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

class ChatMessage {
  final String text;
  final ChatUser user;
  final DateTime createdAt;

  ChatMessage({
    required this.text,
    required this.user,
    required this.createdAt,
  });
}

// class ChatUser {
//   final String id;
//   final String name;

//   ChatUser({
//     required this.id,
//     required this.name,
//   });
// }
