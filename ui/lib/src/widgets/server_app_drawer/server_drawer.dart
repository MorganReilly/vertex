import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:vertex_ui/src/widgets/server_drawer_option/server_drawer_list_builder.dart';
import 'package:vertex_ui/src/widgets/server_drawer_option/server_drawer_settings_bar.dart';

import '../server_drawer_option/heading_widget.dart';
import 'server_drawer_mobile.dart';
import 'server_drawer_web.dart';

/// This class displays the server app drawer differently depending on the device the application
/// is running on. This is to allow for a response design across web, mobile & tablet.

class ServerDrawer extends StatelessWidget {
  final bool displayUsersInCall;
  const ServerDrawer({Key key, this.displayUsersInCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Returns the layout type depending on the device the application is running on
    return ScreenTypeLayout(
      mobile: ServerDrawerMobile(),
      desktop: OrientationLayoutBuilder(
        portrait: (context) => ServerDrawerWebPortrait(),
        landscape: (context) => ServerDrawerWebLandscape(),
      ),
    );
  } //End widget builder

// Return app widgets that will display inside the left drawer
  static List<Widget> getDrawerOptions() {
    // These values will be populated from the server // TEST DATA
    return [
      // Elements that are displayed within the app drawer
      // Currently hard coded until server hock in
      HeadingWidget(headingText: 'Server Name'),
      ServerDrawerListBuilder(),
      SizedBox(height: 50),
      ServerDrawerSettingsBar(),
    ];
  }//End function =
}//End class
