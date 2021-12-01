import 'package:flutter/material.dart';

import 'package:feathr/data/account.dart';
import 'package:feathr/services/api.dart';
import 'package:feathr/screens/home.dart';
import 'package:feathr/screens/local.dart';
import 'package:feathr/screens/fedi.dart';
import 'package:feathr/utils/messages.dart';
import 'package:feathr/widgets/drawer.dart';

/// The [Tabs] widget represents the tab wrapper for the main
/// view of the Feathr app.
class Tabs extends StatefulWidget {
  /// Title to use in the Scaffold
  static const String title = 'feathr';

  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  const Tabs({Key? key, required this.apiService}) : super(key: key);

  @override
  State<Tabs> createState() => _TabsState();
}

/// The [_TabsState] class wraps up logic and state for the [Tabs] screen.
class _TabsState extends State<Tabs> {
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
        children: [
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Tabs.title),
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
