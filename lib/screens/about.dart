import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:feathr/widgets/title.dart';

/// The [About] screen displays information about the `Feather` project, its
/// license, contributors, URLs, version and credits, among other things.
class About extends StatefulWidget {
  const About({super.key});

  @override
  AboutState createState() => AboutState();
}

/// [AboutState] wraps the logic and state for the [About] screen.
class AboutState extends State<About> {
  /// Version of the current build of the app, obtained asynchronously.
  String? version;

  /// Build number of the current build of the app, obtained asynchronously.
  String? buildNumber;

  @override
  void initState() {
    super.initState();
    fetchVersionNumber();
  }

  /// Obtains and stores the current version number in the widget's state.
  Future<void> fetchVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  /// Returns a version tag as a `String`.
  String getVersionTag() {
    if (version != null) {
      return "Version $version (build: $buildNumber)";
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Center(child: TitleWidget("feathr")),
                Text(getVersionTag()),
                const Divider(),
                const Text(
                  "feathr is a free, open source project created by Andrés Ignacio Torres (github: @aitorres).",
                ),
                const Divider(),
                const Text(
                  "feathr is licensed under the GNU Affero General Public License.",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
