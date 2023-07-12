import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:feathr/services/api.dart';
import 'package:feathr/utils/messages.dart';
import 'package:feathr/widgets/instance_form.dart';
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
  Future<void> fetchVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  /// Determines whether the user is logged-in or not, and sets up the widget
  /// for the next action in either case.
  Future<void> checkAuthStatus() async {
    // Attempts to restore the API service status from the device's
    // secure storage
    await widget.apiService.loadApiServiceFromStorage();

    // If the previous call successfully restored the API status, then the
    // `helper` was appropriately instanced.
    if (widget.apiService.helper != null) {
      AccessTokenResponse? token =
          await widget.apiService.helper!.getTokenFromStorage();

      // This would check if, besides having a working `helper`, we also have
      // a user token stored.
      if (token != null) {
        // At this point we have a valid API service instance. This call will
        // attempt to load data, and if it fails, it'd reset the API service
        // status and come back to the log-in screen.
        return onValidAuth();
      }
    }

    // At this point, we can safely assume we need the user to log in
    return setState(() {
      showLoginButton = true;
    });
  }

  /// Displays a form that asks the user for a Mastodon instance URL and
  /// triggers the log in process on successful submit.
  void selectInstanceAction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter your Mastodon instance"),
        content: InstanceForm(onSuccessfulSubmit: logInAction),
      ),
    );
  }

  /// Helper function to report an error during the log in process, making
  /// sure that we also clean the API state (to err on the side of caution)
  void reportLogInError(String message) {
    setState(() {
      showLoginButton = true;
    });
    widget.apiService.resetApiServiceState();
    showSnackBar(
      context,
      message,
    );
  }

  /// Attempts to register an app on a Mastodon instance (given by its URL),
  /// and then attempts to request the user to log in, using the API service.
  Future<void> logInAction(String instanceUrl) async {
    // This triggers the loading spinner. `reportLogInError` would revert this,
    // if it gets called.
    setState(() {
      showLoginButton = false;
    });

    // Attempting to register `feathr` as an app on the user-specified instance
    try {
      await widget.apiService.registerApp(instanceUrl);
    } on ApiException {
      return reportLogInError(
        "We couldn't connect to $instanceUrl as a Mastodon instance. Please check the URL and try again!",
      );
    }

    // We could register the app succesfully. Attempting to log in the user.
    try {
      return onValidAuth();
    } on ApiException {
      return reportLogInError(
        "We couldn't log you in with your specified credentials. Please try again!",
      );
    }
  }

  /// Logs in a user and routes them to the tabbed timeline view.
  void onValidAuth() async {
    final account = await widget.apiService.logIn();

    if (context.mounted) {
      showSnackBar(
        context,
        "Successfully logged in. Welcome, ${account.username}!",
      );
      Navigator.pushNamedAndRemoveUntil(context, '/tabs', (route) => false);
    }
  }

  /// Returns a version tag as a `String`.
  String getVersionTag() {
    if (version != null) {
      return "Version $version";
    }

    return "";
  }

  /// Returns either a loading indicator or a login button, depending
  /// on a boolean state variable, intended to show the right widget
  /// while the app checks if the user is logged in.
  Widget getActionWidget() {
    if (!showLoginButton) {
      return const CircularProgressIndicator();
    }

    return FeathrActionButton(
      onPressed: selectInstanceAction,
      buttonText: "Get started",
    );
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
