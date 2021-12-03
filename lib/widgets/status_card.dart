import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';

import 'package:feathr/data/status.dart';

/// The [StatusCard] widget wraps and displays information for a given
/// [Status] instance.
class StatusCard extends StatelessWidget {
  /// The [Status] instance that will be displayed with this widget.
  final Status status;

  const StatusCard(this.status, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: display more information on each status
    // TODO: main text color (Colors.white) should change depending on theme
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              foregroundImage: status.account.avatarUrl != null
                  ? NetworkImage(status.account.avatarUrl!)
                  : null,
            ),
            title: Text(status.account.displayName),
            subtitle: Text(
              status.account.username,
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Html(
              data: status.content,
              style: {
                'p': Style(
                  color: Colors.white.withOpacity(0.6),
                )
              },
            ),
          ),
          // TODO: add a button bar
        ],
      ),
    );
  }
}
