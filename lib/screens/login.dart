import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:feathr/services/api.dart';
import 'package:feathr/utils/messages.dart';
import 'package:feathr/widgets/title.dart';
import 'package:feathr/widgets/buttons.dart';

/// The [Login] screen renders an initial view of the app for unauthenticated
/// users, allowing them to log into the application with their Mastodon
/// credentials.
/// TODO: add tests for this widget
class Login extends StatefulWidget {
  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  const Login({Key? key, required this.apiService}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

/// The [_LoginState] wraps the logic and state for the [Login] screen.
class _LoginState extends State<Login> {
  /// Version of the current build of the app, obtained asynchronously.
  String? version;

  /// Determines whether or not to show the login button
  bool showLoginButton = false;

  @override
  void initState() {
    super.initState();
    fetchVersionNumber();
    checkAuthStatus();
  }

  /// Obtains and stores the current version number in the widget's state.
  fetchVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  /// Determines whether the user is logged-in or not, and sets up the widget
  /// for the next action in either case.
  checkAuthStatus() async {
    AccessTokenResponse? token =
        await widget.apiService.helper.getTokenFromStorage();

    if (token == null) {
      return setState(() {
        showLoginButton = true;
      });
    }

    // Assuming at this point that we have a valid token.
    // TODO: do we need to handle any other case?
    onValidAuth();
  }

  logInAction() async {
    // TODO: store information from the account in persistent storage
    try {
      setState(() {
        showLoginButton = false;
      });
      final account = await widget.apiService.getAccount();
      showSnackBar(
        context,
        "Successfully logged in. Welcome, ${account.username}!",
      );
      onValidAuth();
    } on ApiException {
      setState(() {
        showLoginButton = true;
      });
      showSnackBar(
        context,
        "There was an error during the log in process.",
      );
    }
  }

  onValidAuth() {
    Navigator.pushNamedAndRemoveUntil(context, '/tabs', (route) => false);
  }

  /// Returns a version tag as a `String`.
  String getVersionTag() {
    if (version != null) {
      return "Version $version";
    }

    return "Unknown version";
  }

  /// Returns either a loading indicator or a login button, depending
  /// on a boolean state variable, intended to show the right widget
  /// while the app checks if the user is logged in.
  Widget getActionWidget() {
    if (!showLoginButton) {
      return const CircularProgressIndicator();
    }

    return FeathrActionButton(
      onPressed: logInAction,
      buttonText: "Log in",
    );
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
                  child: TitleWidget("feathr"),
                ),
                Text(getVersionTag()),
              ],
            ),
            getActionWidget(),
          ],
        ),
      ),
    );
  }
}
