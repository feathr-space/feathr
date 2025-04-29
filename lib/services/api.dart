import 'dart:convert';
import 'dart:collection';

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
enum TimelineType { home, local, fedi, user }

/// [ApiService] holds a collection of useful auxiliary functions to
/// interact with Mastodon's API.
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

  /// [http.Client] instance to perform queries (is overriden for tests)
  http.Client httpClient = http.Client();

  /// Cache for custom emojis per Mastodon instance
  final Map<String, Map<String, String>> _customEmojisCache = HashMap();

  /// Performs a GET request to the specified URL through the API helper
  Future<http.Response> _apiGet(String url) async {
    return await helper!.get(url, httpClient: httpClient);
  }

  /// Performs a POST request to the specified URL through the API helper
  Future<http.Response> _apiPost(String url) async {
    return await helper!.post(url, httpClient: httpClient);
  }

  /// Registers a new `app` on a Mastodon instance and sets the client tokens on
  /// the current state of the API service instance
  Future<void> getClientCredentials() async {
    final apiUrl = "${instanceUrl!}/api/v1/apps";

    // Attempting to register the app
    http.Response resp;
    try {
      resp = await httpClient.post(
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
    int limit, {
    String? accountId,
  }) async {
    // Depending on the type, we select and restrict the api URL to use,
    // limiting the amount of posts we're requesting according to `limit`
    String apiUrl;

    if (timelineType == TimelineType.home) {
      apiUrl = "${instanceUrl!}/api/v1/timelines/home?limit=$limit";
    } else if (timelineType == TimelineType.user) {
      if (accountId == null) {
        throw ApiException(
          "You must provide an `accountId` for the `user` timeline type",
        );
      }

      apiUrl =
          "${instanceUrl!}/api/v1/accounts/$accountId/statuses?limit=$limit";
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

    http.Response resp = await _apiGet(apiUrl);
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
    http.Response resp = await _apiGet(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      currentAccount = Account.fromJson(jsonData);
      return currentAccount!;
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `getAccount`",
    );
  }

  /// Given a [Status]'s ID, requests the Mastodon API to favorite
  /// the status. Note that this is idempotent: an already-favorited
  /// status will remain favorited. Returns the (new) [Status] instance
  /// the API responds with.
  Future<Status> favoriteStatus(String statusId) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses/$statusId/favourite";
    http.Response resp = await _apiPost(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `favoriteStatus`",
    );
  }

  /// Given a [Status]'s ID, requests the Mastodon API to un-favorite
  /// the status. Note that this is idempotent: a non-favorited
  /// status will remain non-favorited. Returns the (new) [Status] instance
  /// the API responds with.
  Future<Status> undoFavoriteStatus(String statusId) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses/$statusId/unfavourite";
    http.Response resp = await _apiPost(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `undoFavoriteStatus`",
    );
  }

  /// Given a status content, requests the Mastodon API to post a new status
  /// on the user's timeline. Returns the (new) [Status] instance the API
  /// responds with.
  Future<Status> postStatus(
    String content, {
    Status? replyToStatus,
    StatusVisibility visibility = StatusVisibility.public,
    String spoilerText = "",
  }) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses";
    // TODO: Support sensitivity, language, scheduling, polls and media
    Map<String, String> body = {
      "status": content,
      "visibility": visibility.name,
      "spoiler_text": spoilerText,
    };
    if (replyToStatus != null) {
      body["in_reply_to_id"] = replyToStatus.id;
    }

    http.Response resp = await helper!.post(
      apiUrl,
      body: body,
      httpClient: httpClient,
    );

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `postStatus`",
    );
  }

  /// Given a [Status]'s ID, requests the Mastodon API to bookmark
  /// the status. Note that this is idempotent: an already-bookmarked
  /// status will remain bookmarked. Returns the (new) [Status] instance
  /// the API responds with.
  Future<Status> bookmarkStatus(String statusId) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses/$statusId/bookmark";
    http.Response resp = await _apiPost(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `bookmarkStatus`",
    );
  }

  /// Given a [Status]'s ID, requests the Mastodon API to un-bookmark
  /// the status. Note that this is idempotent: a non-bookmarked
  /// status will remain non-bookmarked. Returns the (new) [Status] instance
  /// the API responds with.
  Future<Status> undoBookmarkStatus(String statusId) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses/$statusId/unbookmark";
    http.Response resp = await _apiPost(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `undoBookmarkStatus`",
    );
  }

  /// Given a [Status]'s ID, requests the Mastodon API to boost
  /// the status. Note that this is idempotent: an already-boosted
  /// status will remain boosted. Returns the (new) [Status] instance
  /// the API responds with.
  Future<Status> boostStatus(String statusId) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses/$statusId/reblog";
    http.Response resp = await _apiPost(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData["reblog"]);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `boostStatus`",
    );
  }

  /// Given a Mastodon instance's base URL, requests the Mastodon API to
  /// return custom emojis available on that server.
  /// The returned data is a map of shortcode to URL for each custom emoji.
  /// Note that this request is not tied to the current user or its instance,
  /// as it's a public endpoint. Returns a list of custom emojis, if any.
  Future<Map<String, String>> getCustomEmojis(
    String mastodonInstanceUrl,
  ) async {
    final apiUrl = "$mastodonInstanceUrl/api/v1/custom_emojis";
    http.Response resp = await _apiGet(apiUrl);

    if (resp.statusCode == 200) {
      List<dynamic> jsonDataRaw = jsonDecode(resp.body);
      List<Map<String, dynamic>> jsonData =
          jsonDataRaw.map((item) => item as Map<String, dynamic>).toList();

      return {
        for (var item in jsonData)
          item['shortcode'] as String: item['url'] as String,
      };
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `getCustomEmojis`",
    );
  }

  /// Fetches custom emojis for a Mastodon instance, using cache if available
  Future<Map<String, String>> getCachedCustomEmojis(
    String mastodonInstanceUrl,
  ) async {
    if (_customEmojisCache.containsKey(mastodonInstanceUrl)) {
      return _customEmojisCache[mastodonInstanceUrl]!;
    }

    final customEmojis = await getCustomEmojis(mastodonInstanceUrl);
    _customEmojisCache[mastodonInstanceUrl] = customEmojis;
    return customEmojis;
  }

  /// Given a [Status]'s ID, requests the Mastodon API to un-boost
  /// the status. Note that this is idempotent: a non-boosted
  /// status will remain non-boosted. Returns the (new) [Status] instance
  /// the API responds with.
  Future<Status> undoBoostStatus(String statusId) async {
    final apiUrl = "${instanceUrl!}/api/v1/statuses/$statusId/unreblog";
    http.Response resp = await _apiPost(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Status.fromJson(jsonData["reblog"]);
    }

    throw ApiException(
      "Unexpected status code ${resp.statusCode} on `undoBoostStatus`",
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
  Future<void> logOut() async {
    // Revoking credentials on server's side
    final apiUrl = "${instanceUrl!}/oauth/revoke";
    await _apiPost(apiUrl);

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
