import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2_client/oauth2_helper.dart';

import 'package:feathr/helpers/auth.dart';
import 'package:feathr/data/status.dart';
import 'package:feathr/data/account.dart';

/// Custom exception to be thrown by the API service for unhandled cases.
class ApiException implements Exception {
  /// Message or cause of the API exception.
  final String message;

  ApiException(this.message);
}

/// Each [TimelineType] represents a specific set of restrictions for querying
/// a Mastodon timeline.
enum TimelineType { home, local, fedi }

class ApiService {
  /// Access to the device's secure storage to persist session values
  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// URL of the Mastodon instance to perform auth with
  String? instanceUrl;

  /// Client key for authentication with Mastodon
  /// (available after app registration)
  String? oauthClientId;

  /// Client secret for authentication with Mastodon
  /// (available after app registration)
  String? oauthClientSecret;

  /// Helper to make authenticated requests to Mastodon.
  OAuth2Helper? helper;

  /// [Account] instance of the current logged-in user.
  Account? currentAccount;

  /// Registers a new `app` on a Mastodon instance and sets the client tokens on
  /// the current state of the API service instance
  Future<void> getClientCredentials() async {
    final apiUrl = "${instanceUrl!}/api/v1/apps";

    // Attempting to register the app
    http.Response resp;
    try {
      resp = await http.post(
        Uri.parse(apiUrl),
        body: {
          "client_name": "feathr",
          "redirect_uris": featherRedirectUri,
          "scopes": oauthScopes.join(" "),
          "website": "https://feathr.space",
        },
      );
    } on Exception {
      // This probably means that the `instanceUrl` does not actually point
      // towards a valid Mastodon instance
      throw ApiException(
        "Error connecting to server on `getClientCredentials`",
      );
    }

    if (resp.statusCode == 200) {
      // Setting the client tokens
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      oauthClientId = jsonData["client_id"];
      oauthClientSecret = jsonData["client_secret"];
      return;
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `getClientCredentials`",
    );
  }

  /// Creates a new instance of the Oauth Helper with the current state of
  /// the API service instance (if valid), or deletes the current one if
  /// there are null values in the state.
  void setHelper() {
    if (instanceUrl != null &&
        oauthClientId != null &&
        oauthClientSecret != null) {
      helper = getOauthHelper(instanceUrl!, oauthClientId!, oauthClientSecret!);
    } else {
      helper = null;
    }
  }

  /// Given a Mastodon instance URL, attempts to create a new `app` in the
  /// server for `feathr`, updating the device's secure storage in order
  /// to preserve the app tokens and instance URL.
  Future<void> registerApp(String newInstanceUrl) async {
    // Adding the protocol / scheme if needed
    if (!newInstanceUrl.contains("://")) {
      instanceUrl = "https://$newInstanceUrl";
    } else {
      instanceUrl = newInstanceUrl;
    }

    // This call would set `instanceUrl`, `oauthClientId` and
    // `oauthClientSecret` if everything works as expected
    await getClientCredentials();

    // This call would set `helper`
    setHelper();

    // Persisting information in secure storage
    await secureStorage.write(key: "instanceUrl", value: instanceUrl);
    await secureStorage.write(key: "oauthClientId", value: oauthClientId);
    await secureStorage.write(
      key: "oauthClientSecret",
      value: oauthClientSecret,
    );
  }

  /// Attempts to set the API service instance's status from the device's
  /// secure storage. Succeeds if `registerApp` ran before and the
  /// storage has not been deleted. Useful to restore the API service
  /// credentials when restarting the app for a logged in user.
  Future<void> loadApiServiceFromStorage() async {
    instanceUrl = await secureStorage.read(key: "instanceUrl");
    oauthClientId = await secureStorage.read(key: "oauthClientId");
    oauthClientSecret = await secureStorage.read(key: "oauthClientSecret");

    setHelper();
  }

  /// Given a timeline type, an optional maxId and a limit of statuses,
  /// requests the `limit` amount of statuses from the selected timeline
  /// (according to the `timelineType`), using `maxId` as an optional
  /// starting point.
  Future<List<Status>> getStatusList(
    TimelineType timelineType,
    String? maxId,
    int limit,
  ) async {
    // Depending on the type, we select and restrict the api URL to use,
    // limiting the amount of posts we're requesting according to `limit`
    String apiUrl;

    if (timelineType == TimelineType.home) {
      apiUrl = "${instanceUrl!}/api/v1/timelines/home?limit=$limit";
    } else {
      // Both the Local and the Fedi timelines use the same base endpoint
      apiUrl = "${instanceUrl!}/api/v1/timelines/public?limit=$limit";

      if (timelineType == TimelineType.local) {
        apiUrl += "?local=true";
      }
    }

    // If `maxId` is not null, we'll use it as a threshold so that we only
    // get posts older (further down in the timeline) than this one
    if (maxId != null) {
      apiUrl += "?max_id=$maxId";
    }

    http.Response resp = await helper!.get(apiUrl);
    if (resp.statusCode == 200) {
      // The response is a list of json objects
      List<dynamic> jsonDataList = jsonDecode(resp.body);

      return jsonDataList
          .map(
            (statusData) => Status.fromJson(statusData as Map<String, dynamic>),
          )
          .toList();
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `getStatusList`",
    );
  }

  /// Returns the current account as cached in the instance,
  /// retrieving the account details from the API first if needed.
  Future<Account> getCurrentAccount() async {
    if (currentAccount != null) {
      return currentAccount!;
    }

    return await getAccount();
  }

  /// Retrieve and return the [Account] instance associated to the current
  /// credentials by querying the API. Updates the `this.currentAccount`
  /// instance attribute in the process.
  Future<Account> getAccount() async {
    final apiUrl = "${instanceUrl!}/api/v1/accounts/verify_credentials";
    http.Response resp = await helper!.get(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      currentAccount = Account.fromJson(jsonData);
      return currentAccount!;
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `getAccount`",
    );
  }

  /// Performs an authenticated query to the API in order to force the log-in
  /// view. In the process, sets the `this.currentAccount` instance attribute.
  Future<Account> logIn() async {
    // If the user is not authenticated, `helper` will automatically
    // request for authentication while calling this method
    return await getAccount();
  }

  /// Invalidates the stored client tokens server-side and then deletes
  /// all tokens from the secure storage, effectively logging the user out.
  logOut() async {
    // Revoking credentials on server's side
    final apiUrl = "${instanceUrl!}/oauth/revoke";
    await helper!.post(apiUrl);

    // Revoking credentials locally
    await helper!.removeAllTokens();

    // Resetting state of the API service
    await resetApiServiceState();
  }

  /// Revokes all API service credentials & state variables from the
  /// device's secure storage, and sets their values as `null` in the
  /// instance.
  Future<void> resetApiServiceState() async {
    await secureStorage.delete(key: "oauthClientId");
    await secureStorage.delete(key: "oauthClientSecret");
    await secureStorage.delete(key: "instanceUrl");

    oauthClientId = null;
    oauthClientSecret = null;
    instanceUrl = null;
    helper = null;
  }
}
