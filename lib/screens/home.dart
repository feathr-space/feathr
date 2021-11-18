import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

/// The [Home] widget holds a view of the home timeline of
/// a logged in user, to be inserted within the [Tabs] wrapper.
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  /// Icon for the tab wrapper
  static const tabIcon = Tab(
    icon: Icon(FeatherIcons.home),
    text: "Home",
  );

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Home coming soon!"),
    );
  }
}
