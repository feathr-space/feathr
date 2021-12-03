import 'package:flutter/material.dart';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:feathr/data/account.dart';
import 'package:feathr/services/api.dart';
import 'package:feathr/utils/messages.dart';
import 'package:feathr/widgets/drawer.dart';
import 'package:feathr/widgets/timeline.dart';

/// The [TimelineTabs] widget represents the tab wrapper for the main
/// view of the Feathr app.
class TimelineTabs extends StatefulWidget {
  /// Title to use in the Scaffold
  static const String title = 'feathr';

  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  const TimelineTabs({Key? key, required this.apiService}) : super(key: key);

  @override
  State<TimelineTabs> createState() => _TimelineTabsState();
}

/// The [_TimelineTabsState] class wraps up logic and state for the [TimelineTabs] screen.
class _TimelineTabsState extends State<TimelineTabs> {
  Account? account;

  @override
  void initState() {
    super.initState();
    fetchAccount();
  }

  /// Fetches the account stored in the global application state through
  /// the API service, and updates the state of the widget.
  void fetchAccount() async {
    Account currentAccount = await widget.apiService.getCurrentAccount();
    setState(() {
      account = currentAccount;
    });
  }

  /// Renders the header of the application drawer with user data taken
  /// from the application global state, or a spinner.
  Widget getDrawerHeader() {
    if (account != null) {
      return FeathrDrawerHeader(account: account!);
    }

    return const CircularProgressIndicator();
  }

  /// Renders an application drawer, to be used as a complement for navigation
  /// in the app's main tabbed view.
  Widget getDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          getDrawerHeader(),
          ListTile(
            title: const Text('Log out'),
            onTap: () async {
              await widget.apiService.logOut();
              showSnackBar(context, "Logged out successfully. Goodbye!");
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Timeline> tabs = [
      Timeline(
        apiService: widget.apiService,
        timelineType: TimelineType.home,
        tabIcon: const Tab(
          icon: Icon(FeatherIcons.home),
          text: "Home",
        ),
      ),
      Timeline(
        apiService: widget.apiService,
        timelineType: TimelineType.local,
        tabIcon: const Tab(
          icon: Icon(FeatherIcons.monitor),
          text: "Local",
        ),
      ),
      Timeline(
        apiService: widget.apiService,
        timelineType: TimelineType.fedi,
        tabIcon: const Tab(
          icon: Icon(FeatherIcons.globe),
          text: "Fedi",
        ),
      ),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(TimelineTabs.title),
          bottom: TabBar(
            tabs: tabs.map((tab) => tab.tabIcon).toList(),
          ),
        ),
        drawer: getDrawer(context),
        body: TabBarView(
          children: tabs,
        ),
      ),
    );
  }
}
