import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

/// The [Local] widget holds a view of the local timeline of
/// a logged in user, to be inserted within the [Tabs] wrapper.
class Local extends StatelessWidget {
  const Local({Key? key}) : super(key: key);

  /// Icon for the tab wrapper
  static const tabIcon = Tab(
    icon: Icon(FeatherIcons.monitor),
    text: "Local",
  );

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Local coming soon!"),
    );
  }
}
