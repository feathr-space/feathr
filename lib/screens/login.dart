import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:feather/widgets/title.dart';
import 'package:feather/widgets/buttons.dart';

/// The [Login] screen renders an initial view of the app for unauthenticated
/// users, allowing them to log into the application with their Mastodon credentials.
/// TODO: add tests for this widget
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

/// The [_LoginState] wraps the logic and state for the [Login] screen.
class _LoginState extends State<Login> {
  /// Version of the current build of the app, obtained asynchronously.
  String? version;

  @override
  void initState() {
    super.initState();
    fetchVersionNumber();
  }

  /// Obtains and stores the current version number in the widget's state.
  fetchVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  /// Returns a version tag as a `String`.
  String getVersionTag() {
    if (version != null) {
      return "Version $version";
    }

    return "Unknown version";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Center(
                  child: TitleWidget("feather"),
                ),
                Text(getVersionTag()),
              ],
            ),
            FeatherActionButton(
              onPressed: () {},
              buttonText: "Log in",
            ),
          ],
        ),
      ),
    );
  }
}
