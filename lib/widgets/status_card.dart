import 'package:feathr/screens/user.dart';
import 'package:feathr/services/api.dart';
import 'package:feathr/widgets/status_form.dart';
import 'package:flutter/material.dart';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:feathr/data/status.dart';
import 'package:feathr/utils/messages.dart';

/// The [StatusCard] widget wraps and displays information for a given
/// [Status] instance.
class StatusCard extends StatefulWidget {
  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  /// The [Status] instance that will be displayed with this widget (initially).
  final Status initialStatus;

  const StatusCard(this.initialStatus, {super.key, required this.apiService});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  /// The [Status] instance that will be displayed with this widget.
  late Status status;

  @override
  void initState() {
    status = widget.initialStatus;
    super.initState();
  }

  /// Given the current state of an action (e.g., favorited, bookmarked, boosted),
  /// and functions to both undo and do the action, this method will
  /// toggle the status of the action by calling the appropriate API methods.
  Future<void> _handleStatusAction(
    bool currentState,
    Future<Status> Function() undoAction,
    Future<Status> Function() doAction,
  ) async {
    Status newStatus;

    try {
      if (currentState) {
        newStatus = await undoAction();
      } else {
        newStatus = await doAction();
      }
    } on ApiException {
      if (mounted) {
        showSnackBar(
          context,
          "We couldn't perform that action, please try again!",
        );
      }
      return;
    }

    setState(() {
      status = newStatus;
    });
  }

  /// Makes a call unto the Mastodon API in order to (un)favorite the current
  /// toot, and updates the toot's state in the current widget accordingly.
  void onFavoritePress() async {
    await _handleStatusAction(
      status.favorited,
      () => widget.apiService.undoFavoriteStatus(status.id),
      () => widget.apiService.favoriteStatus(status.id),
    );
  }

  /// Makes a call unto the Mastodon API in order to (un)bookmark the current
  /// toot, and updates the toot's state in the current widget accordingly.
  void onBookmarkPress() async {
    await _handleStatusAction(
      status.bookmarked,
      () => widget.apiService.undoBookmarkStatus(status.id),
      () => widget.apiService.bookmarkStatus(status.id),
    );
  }

  /// Makes a call unto the Mastodon API in order to (un)boost the current
  /// toot, and updates the toot's state in the current widget accordingly.
  void onBoostPress() async {
    await _handleStatusAction(
      status.reblogged,
      () => widget.apiService.undoBoostStatus(status.id),
      () => widget.apiService.boostStatus(status.id),
    );
  }

  // Displays a popup window with the reply screen for the selected toot.
  void onReplyPress() {
    StatusForm.displayStatusFormWindow(
      context,
      widget.apiService,
      replyToStatus: status,
    );
  }

  static const Map<StatusVisibility, String> _visibilityIcons = {
    StatusVisibility.public: "🌍",
    StatusVisibility.unlisted: "🔒",
    StatusVisibility.private: "🔐",
  };

  String getStatusSubtitle() {
    final visibilityIcon = _visibilityIcons[status.visibility] ?? "";
    return "$visibilityIcon${status.account.acct}";
  }

  @override
  Widget build(BuildContext context) {
    // TODO: display more information on each status
    // TODO: main text color (Colors.white) should change depending on theme
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: GestureDetector(
              onTap: () {
                // Navigate to the User screen passing the account object
                Navigator.pushNamed(
                  context,
                  '/user',
                  arguments: UserScreenArguments(status.account),
                );
              },
              child: CircleAvatar(
                foregroundImage: status.account.avatarUrl != null
                    ? NetworkImage(status.account.avatarUrl!)
                    : null,
              ),
            ),
            title: Text(
              status.account.displayName != ""
                  ? status.account.displayName
                  : status.account.username,
            ),
            subtitle: Text(
              getStatusSubtitle(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.0,
              ),
            ),
            trailing: Text(
              status.getRelativeDate(),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Html(
              data: status.getContent(),
              style: {
                'p': Style(color: Colors.white.withAlpha(153)),
                'a': Style(textDecoration: TextDecoration.none),
              },
              // TODO: handle @mentions and #hashtags differently
              onLinkTap: (url, renderContext, attributes) => {
                if (url != null) {launchUrl(Uri.parse(url))},
              },
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onReplyPress,
                    tooltip: "Reply",
                    icon: const Icon(FeatherIcons.messageCircle),
                    color: null,
                  ),
                  Text("${status.repliesCount}"),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onBoostPress,
                    tooltip: "Boost",
                    icon: const Icon(FeatherIcons.repeat),
                    color: status.reblogged ? Colors.green : null,
                  ),
                  Text("${status.reblogsCount}"),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onFavoritePress,
                    tooltip: "Favorite",
                    icon: const Icon(FeatherIcons.star),
                    color: status.favorited ? Colors.orange : null,
                  ),
                  Text("${status.favouritesCount}"),
                ],
              ),
              IconButton(
                onPressed: onBookmarkPress,
                tooltip: "Bookmark",
                icon: const Icon(FeatherIcons.bookmark),
                color: status.bookmarked ? Colors.blue : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
