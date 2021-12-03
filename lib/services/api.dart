import 'dart:convert';

import 'package:http/http.dart' as http;
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
  /// URL of the Mastodon instance to perform auth with
  // TODO: let the user set their instance
  static const instanceUrl = "https://mastodon.social";

  /// Helper to make authenticated requests to Mastodon.
  final OAuth2Helper helper = getOauthHelper(instanceUrl);

  /// [Account] instance of the current logged-in user.
  Account? currentAccount;

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
      apiUrl = "$instanceUrl/api/v1/timelines/home?limit=$limit";
    } else {
      // Both the Local and the Fedi timelines use the same base endpoint
      apiUrl = "$instanceUrl/api/v1/timelines/public?limit=$limit";

      if (timelineType == TimelineType.local) {
        apiUrl += "?local=true";
      }
    }

    // If `maxId` is not null, we'll use it as a threshold so that we only
    // get posts older (further down in the timeline) than this one
    if (maxId != null) {
      apiUrl += "?max_id=$maxId";
    }

    http.Response resp = await helper.get(apiUrl);

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
    const apiUrl = "$instanceUrl/api/v1/accounts/verify_credentials";
    http.Response resp = await helper.get(apiUrl);

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
    const apiUrl = "$instanceUrl/oauth/revoke";
    await helper.post(apiUrl);

    // Revoking credentials locally
    await helper.removeAllTokens();
  }
}
