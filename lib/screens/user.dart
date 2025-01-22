import 'package:feathr/services/api.dart';
import 'package:feathr/widgets/drawer.dart';
import 'package:feathr/widgets/timeline.dart';
import 'package:flutter/material.dart';

import 'package:feathr/data/account.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class UserScreenArguments {
  final Account account;

  UserScreenArguments(this.account);
}

/// The [User] screen displays information about any user profile,
/// whether it's the currently-logged user or not.
class User extends StatefulWidget {
  /// The user's account information.
  final Account account;

  /// The [ApiService] instance to use in the widget.
  final ApiService apiService;

  const User({super.key, required this.account, required this.apiService});

  @override
  UserState createState() => UserState();
}

/// [UserState] wraps the logic and state for the [User] screen.
class UserState extends State<User> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// TODO: Add more details about the user profile (e.g. bio, etc).
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FeathrDrawerHeader(account: widget.account),
          Expanded(
            child: Timeline(
              apiService: widget.apiService,
              timelineType: TimelineType.user,
              tabIcon: const Tab(
                icon: Icon(FeatherIcons.user, size: 16),
                text: "User",
              ),
              accountId: widget.account.id,
            ),
          ),
        ],
      ),
    );
  }
}
