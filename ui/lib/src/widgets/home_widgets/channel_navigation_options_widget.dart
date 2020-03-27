import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vertex_ui/locator.dart';
import 'package:vertex_ui/src/routing/route_names.dart';
import 'package:vertex_ui/src/services/client_stubs/lib/api.dart';
import 'package:vertex_ui/src/services/navigation_service.dart';

class ChannelNavigationOptionsWidget extends StatelessWidget {
  const ChannelNavigationOptionsWidget({
    Key key,
    @required this.channel,
  }) : super(key: key);

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
            icon: Icon(FontAwesomeIcons.commentDots),
            onPressed: () => locatorHome<NavigationServiceHome>()
                .navigateTo(MessageRoute, arguments: channel)),
        SizedBox(width: 25),
        IconButton(
            icon: Icon(FontAwesomeIcons.phone),
            onPressed: () => locatorHome<NavigationServiceHome>()
                .navigateTo(VoiceChannelRoute, arguments: channel)),
        SizedBox(width: 25),
        IconButton(
            icon: Icon(FontAwesomeIcons.home),
            onPressed: () => locatorHome<NavigationServiceHome>()
                .navigateTo(LandingPageRoute)),
      ],
    );
  }
}