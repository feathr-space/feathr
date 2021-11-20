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
}
