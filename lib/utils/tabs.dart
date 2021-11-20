import 'package:feathr/services/api.dart';
import 'package:flutter/material.dart';

import 'package:feathr/screens/home.dart';
import 'package:feathr/screens/local.dart';
import 'package:feathr/screens/fedi.dart';
import 'package:feathr/utils/messages.dart';

/// The [Tabs] widget represents the tab wrapper for the main
/// view of the Feathr app.
class Tabs extends StatelessWidget {
  /// Title to use in the Scaffold
  static const String title = 'feathr';

  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  const Tabs({Key? key, required this.apiService}) : super(key: key);

  /// Renders an application drawer, to be used as a complement for navigation
  /// in the app's main tabbed view.
  Widget getDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // TODO: fill-in with user information, see [UserAccountsDrawerHeader]
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Log out'),
            onTap: () async {
              await apiService.logOut();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(title),
          bottom: const TabBar(
            tabs: [
              Home.tabIcon,
              Local.tabIcon,
              Fedi.tabIcon,
            ],
          ),
        ),
        drawer: getDrawer(context),
        body: const TabBarView(
          children: [
            Home(),
            Local(),
            Fedi(),
          ],
        ),
      ),
    );
  }
}
