import 'package:flutter/material.dart';

import 'package:feathr/screens/home.dart';
import 'package:feathr/screens/local.dart';
import 'package:feathr/screens/fedi.dart';

/// The [Tabs] widget represents the tab wrapper for the main
/// view of the Feathr app.
class Tabs extends StatelessWidget {
  const Tabs({Key? key}) : super(key: key);

  static const String title = 'feathr';
  static const Widget titleWidget = Center(
    child: Text(title),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: titleWidget,
          bottom: const TabBar(
            tabs: [
              Home.tabIcon,
              Local.tabIcon,
              Fedi.tabIcon,
            ],
          ),
        ),
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
