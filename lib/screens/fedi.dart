import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

/// The [fedi] widget holds a view of the federated timeline of
/// a logged in user, to be inserted within the [Tabs] wrapper.
class Fedi extends StatelessWidget {
  const Fedi({Key? key}) : super(key: key);

  /// Icon for the tab wrapper
  static const tabIcon = Tab(
    icon: Icon(FeatherIcons.globe),
    text: "Fedi",
  );

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Fedi coming soon!"),
    );
  }
}
