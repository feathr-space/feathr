import 'package:flutter_test/flutter_test.dart';

import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:feathr/services/api.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'api_test.mocks.dart';

@GenerateMocks([http.Client])
@GenerateMocks([OAuth2Helper])
void main() {
  test('setHelper properly creates an OauthHelper if/when needed', () async {
    final apiService = ApiService();
    expect(apiService.oauthClientId, isNull);
    expect(apiService.oauthClientSecret, isNull);
    expect(apiService.instanceUrl, isNull);

    expect(apiService.helper, isNull);
    apiService.setHelper();
    expect(apiService.helper, isNull);

    apiService.instanceUrl = "https://example.org";
    apiService.oauthClientId = "test12345";
    apiService.oauthClientSecret = "test98765";
    apiService.setHelper();
    expect(apiService.helper, isA<OAuth2Helper>());
  });

  group('ApiService.getClientCredentials', () {
    test(
      'getClientCredentials stores app credentials on a successful api request',
      () async {
        final client = MockClient();
        final apiService = ApiService();
        apiService.httpClient = client;

        expect(apiService.oauthClientId, isNull);
        expect(apiService.oauthClientSecret, isNull);

        apiService.instanceUrl = "https://example.org";
        when(client.post(
          Uri.parse('https://example.org/api/v1/apps'),
          body: {
            "client_name": "feathr",
            "redirect_uris": 'space.feathr.app://oauth-callback',
            "scopes": "read write follow",
            "website": "https://feathr.space",
          },
        )).thenAnswer(
          (_) async => http.Response(
            '{"client_id": "12345678", "client_secret": "987654321"}',
            200,
          ),
        );
        await apiService.getClientCredentials();

        expect(apiService.oauthClientId, equals("12345678"));
        expect(apiService.oauthClientSecret, equals("987654321"));
      },
    );

    test(
      'getClientCredentials handles error cases from the api',
      () async {
        final client = MockClient();
        final apiService = ApiService();
        apiService.httpClient = client;

        expect(apiService.oauthClientId, isNull);
        expect(apiService.oauthClientSecret, isNull);

        apiService.instanceUrl = "https://example.org";
        when(client.post(
          Uri.parse('https://example.org/api/v1/apps'),
          body: {
            "client_name": "feathr",
            "redirect_uris": 'space.feathr.app://oauth-callback',
            "scopes": "read write follow",
            "website": "https://feathr.space",
          },
        )).thenAnswer(
          (_) async => http.Response(
            '{"error": "Error message"}',
            422,
          ),
        );
        expect(
          () async => await apiService.getClientCredentials(),
          throwsA(isA<ApiException>()),
        );

        expect(apiService.oauthClientId, isNull);
        expect(apiService.oauthClientSecret, isNull);
      },
    );

    test(
      'favoriteStatus performs favorite action successfully',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/favourite",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"id":"$testStatusId","content":"<p>I am a toot!</p>","favourited":true,"bookmarked":false,"reblogged":true,"account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
            200,
          ),
        );

        final outputStatus = await apiService.favoriteStatus(testStatusId);
        expect(outputStatus.id, equals(testStatusId));
        expect(outputStatus.content, equals("<p>I am a toot!</p>"));
        expect(outputStatus.favorited, isTrue);
        expect(outputStatus.bookmarked, isFalse);
        expect(outputStatus.reblogged, isTrue);
        expect(outputStatus.account.id, equals("this is an id"));
        expect(outputStatus.account.username, equals("username123"));
        expect(outputStatus.account.displayName, equals("user display name"));
        expect(outputStatus.account.isLocked, isFalse);
        expect(outputStatus.account.isBot, isTrue);
        expect(outputStatus.account.avatarUrl, equals("avatar-url"));
        expect(outputStatus.account.headerUrl, equals("header-url"));
      },
    );

    test(
      'favoriteStatus handles api errors as expected',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/favourite",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"error": "Error message"}',
            422,
          ),
        );

        expect(
          () async => await apiService.favoriteStatus(testStatusId),
          throwsA(isA<ApiException>()),
        );
      },
    );

    test(
      'undoFavoriteStatus performs favorite action successfully',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/unfavourite",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"id":"$testStatusId","content":"<p>I am a toot!</p>","favourited":false,"bookmarked":false,"reblogged":true,"account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
            200,
          ),
        );

        final outputStatus = await apiService.undoFavoriteStatus(testStatusId);
        expect(outputStatus.id, equals(testStatusId));
        expect(outputStatus.content, equals("<p>I am a toot!</p>"));
        expect(outputStatus.favorited, isFalse);
        expect(outputStatus.bookmarked, isFalse);
        expect(outputStatus.reblogged, isTrue);
        expect(outputStatus.account.id, equals("this is an id"));
        expect(outputStatus.account.username, equals("username123"));
        expect(outputStatus.account.displayName, equals("user display name"));
        expect(outputStatus.account.isLocked, isFalse);
        expect(outputStatus.account.isBot, isTrue);
        expect(outputStatus.account.avatarUrl, equals("avatar-url"));
        expect(outputStatus.account.headerUrl, equals("header-url"));
      },
    );

    test(
      'undoFavoriteStatus handles api errors as expected',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/unfavourite",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"error": "Error message"}',
            422,
          ),
        );

        expect(
          () async => await apiService.undoFavoriteStatus(testStatusId),
          throwsA(isA<ApiException>()),
        );
      },
    );

    test(
      'bookmarkStatus performs favorite action successfully',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/bookmark",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"id":"$testStatusId","content":"<p>I am a toot!</p>","favourited":true,"bookmarked":true,"reblogged":true,"account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
            200,
          ),
        );

        final outputStatus = await apiService.bookmarkStatus(testStatusId);
        expect(outputStatus.id, equals(testStatusId));
        expect(outputStatus.content, equals("<p>I am a toot!</p>"));
        expect(outputStatus.favorited, isTrue);
        expect(outputStatus.bookmarked, isTrue);
        expect(outputStatus.reblogged, isTrue);
        expect(outputStatus.account.id, equals("this is an id"));
        expect(outputStatus.account.username, equals("username123"));
        expect(outputStatus.account.displayName, equals("user display name"));
        expect(outputStatus.account.isLocked, isFalse);
        expect(outputStatus.account.isBot, isTrue);
        expect(outputStatus.account.avatarUrl, equals("avatar-url"));
        expect(outputStatus.account.headerUrl, equals("header-url"));
      },
    );

    test(
      'bookmarkStatus handles api errors as expected',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/bookmark",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"error": "Error message"}',
            422,
          ),
        );

        expect(
          () async => await apiService.bookmarkStatus(testStatusId),
          throwsA(isA<ApiException>()),
        );
      },
    );

    test(
      'undoBookmarkStatus performs favorite action successfully',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/unbookmark",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response(
            '{"id":"$testStatusId","content":"<p>I am a toot!</p>","favourited":false,"bookmarked":false,"reblogged":true,"account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
            200,
          ),
        );

        final outputStatus = await apiService.undoBookmarkStatus(testStatusId);
        expect(outputStatus.id, equals(testStatusId));
        expect(outputStatus.content, equals("<p>I am a toot!</p>"));
        expect(outputStatus.favorited, isFalse);
        expect(outputStatus.bookmarked, isFalse);
        expect(outputStatus.reblogged, isTrue);
        expect(outputStatus.account.id, equals("this is an id"));
        expect(outputStatus.account.username, equals("username123"));
        expect(outputStatus.account.displayName, equals("user display name"));
        expect(outputStatus.account.isLocked, isFalse);
        expect(outputStatus.account.isBot, isTrue);
        expect(outputStatus.account.avatarUrl, equals("avatar-url"));
        expect(outputStatus.account.headerUrl, equals("header-url"));
      },
    );

    test(
      'undoBookmarkStatus handles api errors as expected',
      () async {
        final mockClient = MockClient();
        final mockHelper = MockOAuth2Helper();
        final apiService = ApiService();
        apiService.helper = mockHelper;
        apiService.httpClient = mockClient;
        apiService.instanceUrl = "https://example.org";

        const testStatusId = "12345";

        when(mockHelper.post(
                "https://example.org/api/v1/statuses/$testStatusId/unbookmark",
                httpClient: mockClient))
            .thenAnswer(
          (_) async => http.Response('{"error": "Error message"}', 422),
        );

        expect(
          () async => await apiService.undoBookmarkStatus(testStatusId),
          throwsA(isA<ApiException>()),
        );
      },
    );
  });
}
