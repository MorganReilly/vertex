import 'package:flutter/material.dart';
import 'package:vertex_ui/src/services/client_stubs/lib/api.dart';

class ChannelNameWidget extends StatelessWidget {
  const ChannelNameWidget({
    Key key,
    @required this.channel,
  }) : super(key: key);

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(channel.name, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
} //End class
