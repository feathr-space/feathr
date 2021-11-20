import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

/// Custom URI scheme used for redirection after auth
const String featherUriScheme = 'space.feathr.app';

/// URI for redirection after successful auth
const String featherRedirectUri = 'space.feathr.app://oauth-callback';

/// Client key for authentication with Mastodon (taken from env vars).
final String oauthClientId = dotenv.get("OAUTH_CLIENT_ID");

/// Client secret for authentication with Mastodon (taken from env vars).
final String oauthClientSecret = dotenv.get("OAUTH_CLIENT_SECRET");

/// The [FeathrOAuth2Client] is a custom [OAuth2Client] class for use with
/// a Mastodon instance's OAuth2 endpoints.
class FeathrOAuth2Client extends OAuth2Client {
  /// URL of the Mastodon instance to perform auth with
  final String instanceUrl;

  FeathrOAuth2Client({required this.instanceUrl})
      : super(
          authorizeUrl: '$instanceUrl/oauth/authorize',
          tokenUrl: '$instanceUrl/oauth/token',
          redirectUri: featherRedirectUri,
          customUriScheme: featherUriScheme,
        );
}

/// Returns an instance of the [OAuth2Helper] helper class that serves as a
/// bridge between the OAuth2 auth flow and requests to Mastodon's endpoint.
OAuth2Helper getOauthHelper(String instanceUrl) {
  final FeathrOAuth2Client oauthClient =
      FeathrOAuth2Client(instanceUrl: instanceUrl);

  return OAuth2Helper(
    oauthClient,
    grantType: OAuth2Helper.AUTHORIZATION_CODE,
    clientId: oauthClientId,
    clientSecret: oauthClientSecret,
    scopes: ['read', 'write', 'follow'],
  );
}
