import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  /// Helper method to access the device's secure storage
  static const storage = FlutterSecureStorage();

  /// Helper to make authenticated requests to Mastodon.
  final OAuth2Helper helper = getOauthHelper(instanceUrl);

  Future<Account> getAccount() async {
    const apiUrl = "$instanceUrl/api/v1/accounts/verify_credentials";
    http.Response resp = await helper.get(apiUrl);

    if (resp.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resp.body);
      return Account.fromJson(jsonData);
    }

    throw ApiException(
        "Unexpected status code ${resp.statusCode} on `getAccount`");
  }

  Future<Account> logIn() async {
    // If the user is not authenticated, `helper` will automatically
    // request for authentication while calling this method
    final account = await getAccount();

    // Persisting some user information to use in the UI
    await storage.write(key: "username", value: account.username);
    await storage.write(key: "displayName", value: account.displayName);
    await storage.write(key: "avatarUrl", value: account.avatarUrl);
    await storage.write(key: "headerUrl", value: account.headerUrl);

    return account;
  }

  logOut() async {
    // Revoking credentials on server's side
    const apiUrl = "$instanceUrl/oauth/revoke";
    await helper.post(apiUrl);

    // Revoking credentials locally
    await helper.removeAllTokens();
  }
}
