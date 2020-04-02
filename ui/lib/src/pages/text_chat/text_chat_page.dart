import 'dart:html';

/// G00303598 -- Morgan Reilly
/// Text Chat Page
/// TODO: Link with Database
/// TODO: Link with user logged in

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vertex_ui/src/services/client_stubs/lib/api.dart';
import '../../utils/device_info.dart'
    if (dart.library.js) '../../utils/device_info_web.dart';
import '../../utils/websocket.dart'
    if (dart.library.js) '../../utils/websocket_web.dart';
import 'dart:async';
import 'dart:io';

/// MessageScreen -> Stateful Widget
class MessageScreen extends StatefulWidget {
  final int id; // Message id
  final String content; // Content of message
  final int timestamp; // Unix epoch time-stamp of message

  // Stateful Widget Constructor
  MessageScreen(
      {Key key,
      this.id,
      Channel channel,
      User author,
      this.content,
      this.timestamp})
      : super(key: key);

  @override
  State createState() => MessageScreenState();
}

/// Message Screen State -> State<MessageScreen>
class MessageScreenState extends State<MessageScreen>
    with TickerProviderStateMixin {
  // Message Screen State Constructor
  MessageScreenState({Key key, this.id, this.content, this.timestamp});

  // Variables to match database
  int id; // Message id
  String content; // Content of message
  int timestamp; // Unix epoch time-stamp of message

  // Internal Message Variables
  List<ChatMessage> messageList = <ChatMessage>[];
  SharedPreferences preferences;
  bool isComposing = false;

  // Message Controllers
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController scrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    print("text_chat_page.initState()");
    print(id.toString()); // Check id
  }

  /// Dispose of animation when finished
  @override
  void dispose() {
    for (ChatMessage message in messageList) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  /// -- Send a message --
  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: textEditingController,
              onChanged: (String text) {
                setState(() => isComposing = text.length > 0);
              },
              onSubmitted: handleSubmitted,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: isComposing
                  ? () => handleSubmitted(textEditingController.text)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void handleSubmitted(String text) {
    print("handleSubmitted()");
    textEditingController.clear();
    setState(() {
      isComposing = false;
    });
    ChatMessage message = ChatMessage(
      content: text,
      animationController: AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    setState(() {
      messageList.insert(0, message);
    });
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          //Heading
          Container(
            color: Colors.black26,
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Text Channel Name (General)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => messageList[index],
              itemCount: messageList.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

/// Handles displaying the message in the chat screen
class ChatMessage extends StatelessWidget {
  final int id; // Message id
  final String content; // Content of message
  final int timestamp; // Unix epoch time-stamp of message
  final AnimationController animationController;

  ChatMessage(
      {Key key,
      this.id,
      Channel channel,
      User author,
      this.content,
      this.timestamp,
      this.animationController});

  get author => null;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(author.toString())),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(author.toString(),
                      style: Theme.of(context).textTheme.subhead),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(content), // Body of message to display
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } //End builder
} //End class
