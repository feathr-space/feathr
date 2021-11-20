import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oauth2_client/oauth2_helper.dart';

import 'package:feathr/helpers/auth.dart';
import 'package:feathr/data/account.dart';

/// Custom exception to be thrown by the API service for unhandled cases.
class ApiException implements Exception {
  /// Message or cause of the API exception.
  final String message;

  ApiException(this.message);
}

class ApiService {
  /// URL of the Mastodon instance to perform auth with
  // TODO: let the user set their instance
  static const instanceUrl = "https://mastodon.social";

  /// Helper to make authenticated requests to Mastodon.
  final OAuth2Helper helper = getOauthHelper(instanceUrl);

  /// [Account] instance of the current logged-in user.
  Account? currentAccount;

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
        "Unexpected status code ${resp.statusCode} on `getAccount`");
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
