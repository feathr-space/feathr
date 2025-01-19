import 'package:flutter/material.dart';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:feathr/data/account.dart';
import 'package:feathr/services/api.dart';
import 'package:feathr/utils/messages.dart';
import 'package:feathr/widgets/drawer.dart';
import 'package:feathr/widgets/timeline.dart';

import 'package:feathr/widgets/status_form.dart';

/// The [TimelineTabs] widget represents the tab wrapper for the main
/// view of the Feathr app.
class TimelineTabs extends StatefulWidget {
  /// Title to use in the Scaffold
  static const String title = 'feathr';

  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  const TimelineTabs({super.key, required this.apiService});

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
            title: const Text('About feathr'),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/about');
            },
          ),
          ListTile(
            title: const Text('Log out'),
            onTap: () async {
              await widget.apiService.logOut();

              if (context.mounted) {
                showSnackBar(context, "Logged out successfully. Goodbye!");
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Displays a dialog box with a form to post a status.
  void postStatusAction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Compose a new status",
            textAlign: TextAlign.center,
          ),
          titleTextStyle: TextStyle(
            fontSize: 18.0,
          ),
          content: StatusForm(
            apiService: widget.apiService,
            onSuccessfulSubmit: () {
              // Hide the dialog box
              Navigator.of(context).pop();

              // Show a success message
              showSnackBar(context, "Status posted successfully!");
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Timeline> tabs = [
      Timeline(
        apiService: widget.apiService,
        timelineType: TimelineType.home,
        tabIcon: const Tab(
          icon: Icon(FeatherIcons.home, size: 14),
          text: "Home",
        ),
      ),
      Timeline(
        apiService: widget.apiService,
        timelineType: TimelineType.local,
        tabIcon: const Tab(
          icon: Icon(FeatherIcons.monitor, size: 16),
          text: "Local",
        ),
      ),
      Timeline(
        apiService: widget.apiService,
        timelineType: TimelineType.fedi,
        tabIcon: const Tab(
          icon: Icon(FeatherIcons.globe, size: 16),
          text: "Fedi",
        ),
      ),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48.0,
          title: const Text(TimelineTabs.title),
          bottom: TabBar(
            tabs: tabs.map((tab) => tab.tabIcon).toList(),
          ),
        ),
        drawer: getDrawer(context),
        body: Stack(
          children: [
            TabBarView(children: tabs),
            Positioned(
              bottom: 32.0,
              right: 32.0,
              child: FloatingActionButton(
                onPressed: postStatusAction,
                child: const Icon(Icons.create_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
