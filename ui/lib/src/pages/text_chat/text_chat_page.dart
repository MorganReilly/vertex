import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vertex_ui/src/utils/websocket.dart';

class TextChat extends StatelessWidget {
  final String userId;

  //TODO: Other variables in here..

  TextChat({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          'Vertex Chat',
        ),
        centerTitle: true,
      ),
      body: TextChatScreen(
        userId: userId,
      ),
    );
  }
}

class TextChatScreen extends StatefulWidget {
  final String userId;

//  final String channelId;
  TextChatScreen({Key key, this.userId}) : super(key: key);

  @override
  State createState() => TextChatScreenState(userId: userId);
}

class TextChatScreenState extends State<TextChatScreen>
    with TickerProviderStateMixin {
  String userId;
  String id;

  TextChatScreenState({Key key, this.userId});

  // Variable
  List<ChatMessage> _messages = <ChatMessage>[];
  String chatId; // Group chat id / channel id
  SharedPreferences preferences;

  bool isLoading;
  bool isShowSticker;
  bool _isComposing = false;
  static final _formKey = new GlobalKey<FormState>();

//  File imgFile; // May use ?
//  String imgUrl; // May use?

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController scrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  WebSocketTextMessage wbtm = new WebSocketTextMessage("ws://localhost:8765");

//  //Variables
//  final List<ChatMessage> _messages = <ChatMessage>[];
//  final TextEditingController _textEditingController = TextEditingController();
//  bool _isComposing = false;
//  static final _formKey = new GlobalKey<FormState>();
//  WebSocketTextMessage wbtm = new WebSocketTextMessage("ws://localhost:8765");

  @override
  void initState() {
    super.initState();
    print("text_chat_page.initState()");
    wbtm.connect();
    print(wbtm._url);

    chatId = '';

    isLoading = false;
    readLocal();
//    imgUrl = '';
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id') ?? '';
    if (id.hashCode <= userId.hashCode)
      chatId = '$id-$userId';
    else
      chatId = '$userId-$id';

    // TODO: READ FROM DB HERE
    setState(() {});
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear(); // Clear the input box

      // TODO: Send message to server from here?

    } else {
      print("Noting to send");
    }
  }

  /// Dispose of animation when finished
  @override
  void dispose() {
    for (ChatMessage message in _messages) {
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
              key: _formKey,
              controller: textEditingController,
              onChanged: (String text) {
                setState(() => _isComposing = text.length > 0);
              },
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing
                  ? () => _handleSubmitted(textEditingController.text)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    print("handleSubmitted()");
    textEditingController.clear();
    setState(() {
      _isComposing = false;
    });
    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    wbtm.send(message); // TODO: Look at serialising the message?
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
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme
                .of(context)
                .cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

// function to call api to get messages

// get websocket open with simplewebsocket -- different to original one 1
// open to milton
// on open print hello
// check logs of server for connection

/// User name for displaying in message list
const String _name = "User Name"; //TODO: Change this to current user

/// Handles displaying the message in the chat screen
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});

  final String text;
  final AnimationController animationController;

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
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_name[0], style: Theme
                      .of(context)
                      .textTheme
                      .subhead),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text), // Body of message to display
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

/// WebSocketTextMessage
/// This class handles the websocket to use
/// for the text messaging side of the application.
class WebSocketTextMessage {
  String _url;
  var _socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  WebSocketTextMessage(this._url);

  connect() async {
    try {
      _socket = WebSocket(_url);
      _socket.onOpen.listen((e) {
        this?.onOpen();
      });

      _socket.onMessage.listen((e) {
        this?.onMessage(e.data);
      });

      _socket.onClose.listen((e) {
        this?.onClose(e.code, e.reason);
      });
    } catch (e) {
      this?.onClose(e.code, e.reason);
    }
  }

  // use this to send data back to the server
  send(data) {
    if (_socket != null && _socket.readyState == WebSocket.OPEN) {
      _socket.send(data);
      print('send: $data');
    } else {
      print('WebSocket not connected, message $data not sent');
    }
  }

  close() {
    _socket.close();
  }
}
