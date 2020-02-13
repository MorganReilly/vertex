import 'package:flutter/material.dart';
import 'package:vertex_ui/src/pages/home/home_page.dart';
import 'package:vertex_ui/src/widgets/custom_gradient.dart';

/// Each class defined below here is now a part of the App Root node
/// VertexLanding is currently main landing page, meaning the App will
/// load to that page.
/// Stateful class --> Stateful widget.
class CallPage extends StatefulWidget {
  //Member Variables
  final String pageTitle;

  /// Home page of application.
  /// Fields in Widget subclass always marked final
  CallPage({Key key, this.pageTitle}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

/// Stateless class
class _CallPageState extends State<CallPage> {
  /// Build is run and rerun every time above method, setState, is called
  @override
  Widget build(BuildContext context) {
    //Data about the device the application is running on
    final data = MediaQuery.of(context);

    /// Scaffold: framework which implements the basic material
    /// design visual layout structure of the flutter app.
    return Scaffold(
        appBar: AppBar(
          /// Setting AppBar title here
          /// Add in process class duration in appbar so user can see the duration of the current class
          title: Text(
            widget.pageTitle,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              //TODO: Add support for appBar action buttons across all page views in some sort of a class
              icon: Icon(Icons.settings),
            )
          ],
        ),

        /// Center: A widget that centers all children within it
        body: Center(
          child: Stack(
            children: <Widget>[
              // Right video box
              // Added widgets to display video call will be added here
              new Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    gradient: getCustomGradient(),
                  ),
                  //Setting percentage amount of height & width
                  child: Center(
                    // Center all content 'Center'
                    child: Text('External Camera',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white)),
                  )),
              // Left video box
              // Added widgets to display video call will be added here
              new Container(
                  alignment: Alignment.topRight,
                  padding:
                      new EdgeInsets.only(top: 10, right: 10.0, left: 10.0),
                  child: new Container(
                      margin: const EdgeInsets.all(10.0),
                      color: Colors.black,
                      width: data.size.width / 2.5,
                      height: data.size.height / 4.5,
                      child: Center(
                        // Center all content 'Center'
                        child: Text('Local Camera',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ))),
              new Container(
                //Container for the icons
                margin: const EdgeInsets.all(30.0),
                alignment: Alignment.bottomCenter,
                child: new Row(
                  //Row on icons inside the container
                  //Container for call fanatically buttons
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    //TODO: Add over color so when the mouse is over the button it will light up to give a better feedback to the user
                    IconButton(
                      icon: Icon(Icons.call_end, size: 24.0),
                      onPressed: () => _endCall(),
                    ),
                    //Mute mic button
                    IconButton(
                      icon: Icon(Icons.mic, size: 24.0),
                      onPressed: () => _muteMic(),
                    ),
                    // Mute headset button
                    IconButton(
                        icon: Icon(Icons.headset, size: 24.0),
                        onPressed: () => _muteHeadset()),
                  ],
                ),
              )
            ],
          ),
        ));
  } //end Widget build

  //Function to end call and return to home page
  _endCall() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new VertexHomePage(title: "Welcome Home")));
  } //End function

  _muteMic() async {
    //TODO: need to connect with audio settings page I feel
  } //End function

  _muteHeadset() async {
    //TODO: need to connect with audio setting page I feel
  } //End function
} //End class
