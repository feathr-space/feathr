import 'package:feathr/data/account.dart';
import 'package:feathr/data/status.dart';
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
  // Helper method to set up common mock objects and API service
  (ApiService, MockClient, MockOAuth2Helper) setupMockApiService() {
    final mockClient = MockClient();
    final mockHelper = MockOAuth2Helper();
    final apiService = ApiService();
    apiService.helper = mockHelper;
    apiService.httpClient = mockClient;
    apiService.instanceUrl = "https://example.org";
    return (apiService, mockClient, mockHelper);
  }

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

  group('ApiService', () {
    test(
      'getClientCredentials stores app credentials on a successful api request',
      () async {
        final client = MockClient();
        final apiService = ApiService();
        apiService.httpClient = client;

        expect(apiService.oauthClientId, isNull);
        expect(apiService.oauthClientSecret, isNull);

        apiService.instanceUrl = "https://example.org";
        when(
          client.post(
            Uri.parse('https://example.org/api/v1/apps'),
            body: {
              "client_name": "feathr",
              "redirect_uris": 'space.feathr.app://oauth-callback',
              "scopes": "read write follow",
              "website": "https://feathr.space",
            },
          ),
        ).thenAnswer(
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

    test('getClientCredentials handles error responses from the api', () async {
      final client = MockClient();
      final apiService = ApiService();
      apiService.httpClient = client;

      expect(apiService.oauthClientId, isNull);
      expect(apiService.oauthClientSecret, isNull);

      apiService.instanceUrl = "https://example.org";
      when(
        client.post(
          Uri.parse('https://example.org/api/v1/apps'),
          body: {
            "client_name": "feathr",
            "redirect_uris": 'space.feathr.app://oauth-callback',
            "scopes": "read write follow",
            "website": "https://feathr.space",
          },
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );
      expect(
        () async => await apiService.getClientCredentials(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            "Unexpected status code 422 on `getClientCredentials`",
          ),
        ),
      );

      expect(apiService.oauthClientId, isNull);
      expect(apiService.oauthClientSecret, isNull);
    });

    test('getClientCredentials handles exceptions from the api call', () async {
      final client = MockClient();
      final apiService = ApiService();
      apiService.httpClient = client;

      expect(apiService.oauthClientId, isNull);
      expect(apiService.oauthClientSecret, isNull);

      apiService.instanceUrl = "https://example.org";
      when(
        client.post(
          Uri.parse('https://example.org/api/v1/apps'),
          body: {
            "client_name": "feathr",
            "redirect_uris": 'space.feathr.app://oauth-callback',
            "scopes": "read write follow",
            "website": "https://feathr.space",
          },
        ),
      ).thenThrow(Exception("Network error"));

      expect(
        () async => await apiService.getClientCredentials(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            "Error connecting to server on `getClientCredentials`",
          ),
        ),
      );

      expect(apiService.oauthClientId, isNull);
      expect(apiService.oauthClientSecret, isNull);
    });

    test('favoriteStatus performs action successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/favourite",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id":"$testStatusId","created_at": "2025-01-01T00:00:00Z","visibility":"public","emoji":[],"content":"<p>I am a toot!</p>","favourited":true,"bookmarked":false,"reblogged":true,"favourites_count":1,"reblogs_count":3,"replies_count":2,"spoiler_text":"","account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
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
      expect(outputStatus.favouritesCount, equals(1));
      expect(outputStatus.reblogsCount, equals(3));
      expect(outputStatus.repliesCount, equals(2));
      expect(outputStatus.visibility, equals(StatusVisibility.public));
    });

    test('favoriteStatus handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/favourite",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(
        () async => await apiService.favoriteStatus(testStatusId),
        throwsA(isA<ApiException>()),
      );
    });

    test('undoFavoriteStatus performs action successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/unfavourite",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id":"$testStatusId","created_at": "2025-01-01T00:00:00Z","visibility":"private","content":"<p>I am a toot!</p>","favourited":false,"bookmarked":false,"reblogged":true,"favourites_count":1,"reblogs_count":3,"replies_count":2,"spoiler_text":"","account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
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
      expect(outputStatus.visibility, equals(StatusVisibility.private));
    });

    test('undoFavoriteStatus handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/unfavourite",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(
        () async => await apiService.undoFavoriteStatus(testStatusId),
        throwsA(isA<ApiException>()),
      );
    });

    test('bookmarkStatus performs action successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/bookmark",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id":"$testStatusId","created_at": "2025-01-01T00:00:00Z","visibility":"unlisted","content":"<p>I am a toot!</p>","favourited":true,"bookmarked":true,"reblogged":true,"favourites_count":1,"reblogs_count":3,"replies_count":2,"spoiler_text":"","account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
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
      expect(outputStatus.visibility, equals(StatusVisibility.unlisted));
    });

    test('bookmarkStatus handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/bookmark",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(
        () async => await apiService.bookmarkStatus(testStatusId),
        throwsA(isA<ApiException>()),
      );
    });

    test('undoBookmarkStatus performs action successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/unbookmark",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id":"$testStatusId","created_at": "2025-01-01T00:00:00Z","visibility":"public","emoji":[],"content":"<p>I am a toot!</p>","favourited":false,"bookmarked":false,"reblogged":true,"favourites_count":1,"reblogs_count":3,"replies_count":2,"spoiler_text":"","account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}',
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
    });

    test('undoBookmarkStatus handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/unbookmark",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(
        () async => await apiService.undoBookmarkStatus(testStatusId),
        throwsA(isA<ApiException>()),
      );
    });

    test('boostStatus performs action successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/reblog",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"reblog":{"id":"$testStatusId","created_at": "2025-01-01T00:00:00Z","visibility":"public","emoji":[],"content":"<p>I am a toot!</p>","favourited":true,"bookmarked":true,"reblogged":true,"favourites_count":1,"reblogs_count":3,"replies_count":2,"spoiler_text":"","account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}}',
          200,
        ),
      );

      final outputStatus = await apiService.boostStatus(testStatusId);
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
    });

    test('boostStatus handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/reblog",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(
        () async => await apiService.boostStatus(testStatusId),
        throwsA(isA<ApiException>()),
      );
    });

    test('undoBoostStatus performs action successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/unreblog",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"reblog":{"id":"$testStatusId","created_at": "2025-01-01T00:00:00Z","visibility":"public","emoji":[],"content":"<p>I am a toot!</p>","favourited":true,"bookmarked":true,"reblogged":true,"favourites_count":1,"reblogs_count":3,"replies_count":2,"spoiler_text":"","account":{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}}}',
          200,
        ),
      );

      final outputStatus = await apiService.undoBoostStatus(testStatusId);
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
    });

    test('undoBoostStatus handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();
      const testStatusId = "12345";

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses/$testStatusId/unreblog",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(
        () async => await apiService.undoBoostStatus(testStatusId),
        throwsA(isA<ApiException>()),
      );
    });

    test('getAccount retrieves user from api successfully', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.get(
          "https://example.org/api/v1/accounts/verify_credentials",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}',
          200,
        ),
      );

      expect(apiService.currentAccount, isNull);
      final outputAccount = await apiService.getAccount();
      expect(apiService.currentAccount, isNotNull);
      expect(apiService.currentAccount, equals(outputAccount));

      expect(outputAccount.id, equals("this is an id"));
      expect(outputAccount.username, equals("username123"));
      expect(outputAccount.displayName, equals("user display name"));
      expect(outputAccount.isLocked, isFalse);
      expect(outputAccount.isBot, isTrue);
      expect(outputAccount.avatarUrl, equals("avatar-url"));
      expect(outputAccount.headerUrl, equals("header-url"));
    });

    test('getAccount handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.get(
          "https://example.org/api/v1/accounts/verify_credentials",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(apiService.currentAccount, isNull);
      expect(
        () async => await apiService.getAccount(),
        throwsA(isA<ApiException>()),
      );
      expect(apiService.currentAccount, isNull);
    });

    test('getCurrentAccount retrieves user from cache if exists', () async {
      final apiService = ApiService();
      apiService.instanceUrl = "https://example.org";

      final testAccount = Account(
        id: "12345",
        username: "test",
        displayName: "test username",
        acct: "test",
        isLocked: false,
        isBot: false,
      );
      apiService.currentAccount = testAccount;

      // we don't mockup calls so this testt will fail if it tries to call the apis
      final outputAccount = await apiService.getCurrentAccount();
      expect(outputAccount, isNotNull);
      expect(outputAccount, equals(testAccount));
    });

    test(
      'getCurrentAccount retrieves user from api when needed successfully',
      () async {
        final (apiService, mockClient, mockHelper) = setupMockApiService();

        when(
          mockHelper.get(
            "https://example.org/api/v1/accounts/verify_credentials",
            httpClient: mockClient,
          ),
        ).thenAnswer(
          (_) async => http.Response(
            '{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}',
            200,
          ),
        );

        expect(apiService.currentAccount, isNull);
        final outputAccount = await apiService.getCurrentAccount();
        expect(apiService.currentAccount, isNotNull);
        expect(apiService.currentAccount, equals(outputAccount));

        expect(outputAccount.id, equals("this is an id"));
        expect(outputAccount.username, equals("username123"));
        expect(outputAccount.displayName, equals("user display name"));
        expect(outputAccount.isLocked, isFalse);
        expect(outputAccount.isBot, isTrue);
        expect(outputAccount.avatarUrl, equals("avatar-url"));
        expect(outputAccount.headerUrl, equals("header-url"));
      },
    );

    test('getCurrentAccount handles api errors as expected', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.get(
          "https://example.org/api/v1/accounts/verify_credentials",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Error message"}', 422),
      );

      expect(apiService.currentAccount, isNull);
      expect(
        () async => await apiService.getCurrentAccount(),
        throwsA(isA<ApiException>()),
      );
      expect(apiService.currentAccount, isNull);
    });

    test('logIn mirrors behavior of getAccount', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.get(
          "https://example.org/api/v1/accounts/verify_credentials",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id":"this is an id","username":"username123","acct":"username123","display_name":"user display name","locked":false,"bot":true,"avatar":"avatar-url","header":"header-url"}',
          200,
        ),
      );

      expect(apiService.currentAccount, isNull);
      final outputAccount = await apiService.logIn();
      expect(apiService.currentAccount, isNotNull);
      expect(apiService.currentAccount, equals(outputAccount));

      expect(outputAccount.id, equals("this is an id"));
      expect(outputAccount.username, equals("username123"));
      expect(outputAccount.displayName, equals("user display name"));
      expect(outputAccount.isLocked, isFalse);
      expect(outputAccount.isBot, isTrue);
      expect(outputAccount.avatarUrl, equals("avatar-url"));
      expect(outputAccount.headerUrl, equals("header-url"));
    });

    test('getStatusList retrieves a list of statuses from the API', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.get(
          "https://example.org/api/v1/timelines/home?limit=10",
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '[{"id": "1", "created_at": "2025-01-01T00:00:00Z", "visibility": "public", "emoji": [], "content": "<p>Status 1</p>", "favourited": false, "bookmarked": false, "reblogged": false, "favourites_count": 0, "reblogs_count": 0, "replies_count": 2, "spoiler_text": "", "account": {"id": "account1", "username": "user1", "acct": "user1", "display_name": "User One", "locked": false, "bot": false, "avatar": "avatar1-url", "header": "header1-url"}}, {"id": "2", "created_at": "2025-01-02T00:00:00Z", "visibility": "public", "emoji": [], "content": "<p>Status 2</p>", "favourited": false, "bookmarked": false, "reblogged": false, "favourites_count": 0, "reblogs_count": 0, "replies_count": 2, "spoiler_text": "", "account": {"id": "account2", "username": "user2", "acct": "user2", "display_name": "User Two", "locked": false, "bot": false, "avatar": "avatar2-url", "header": "header2-url"}}]',
          200,
        ),
      );

      final statuses = await apiService.getStatusList(
        TimelineType.home,
        null,
        10,
      );

      expect(statuses.length, equals(2));
      expect(statuses[0].id, equals("1"));
      expect(statuses[1].id, equals("2"));
      expect(statuses[0].content, equals("<p>Status 1</p>"));
      expect(statuses[0].account.username, equals("user1"));
      expect(statuses[0].account.displayName, equals("User One"));
      expect(statuses[1].content, equals("<p>Status 2</p>"));
      expect(statuses[1].account.username, equals("user2"));
      expect(statuses[1].account.displayName, equals("User Two"));
    });

    test('getStatusList handles error status codes from the API', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.get(
          "https://example.org/api/v1/timelines/public?limit=10?local=true?max_id=baseId",
          httpClient: mockClient,
        ),
      ).thenAnswer((_) async => http.Response('{}', 503));

      expect(
        () async =>
            await apiService.getStatusList(TimelineType.local, "baseId", 10),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            "Unexpected status code 503 on `getStatusList`",
          ),
        ),
      );
    });

    test(
      'getStatusList handles null accountIds when timeline type is user',
      () async {
        final (apiService, mockClient, mockHelper) = setupMockApiService();

        expect(
          () async =>
              await apiService.getStatusList(TimelineType.user, null, 10),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              "You must provide an `accountId` for the `user` timeline type",
            ),
          ),
        );
      },
    );

    test(
      'postStatus posts a new status and returns the created status',
      () async {
        final (apiService, mockClient, mockHelper) = setupMockApiService();

        when(
          mockHelper.post(
            "https://example.org/api/v1/statuses",
            body: {
              "status": "Hello, world!",
              "visibility": "public",
              "spoiler_text": "",
            },
            httpClient: mockClient,
          ),
        ).thenAnswer(
          (_) async => http.Response(
            '{"id": "1", "created_at": "2025-01-01T00:00:00Z", "visibility": "public", "emoji": [], "content": "<p>Hello, world!</p>", "favourited": false, "bookmarked": false, "reblogged": false, "favourites_count": 0, "reblogs_count": 0, "replies_count": 2, "spoiler_text": "", "account": {"id": "account1", "username": "user1", "acct": "user1", "display_name": "User One", "locked": false, "bot": false, "avatar": "avatar1-url", "header": "header1-url"}}',
            200,
          ),
        );

        final status = await apiService.postStatus("Hello, world!");

        expect(status.id, equals("1"));
        expect(status.content, equals("<p>Hello, world!</p>"));
      },
    );

    test('postStatus handles errors when calling the API', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses",
          body: {
            "status": "Hello, world!",
            "visibility": "public",
            "spoiler_text": "",
          },
          httpClient: mockClient,
        ),
      ).thenAnswer((_) async => http.Response('{}', 400));

      expect(
        () async => await apiService.postStatus("Hello, world!"),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            "Unexpected status code 400 on `postStatus`",
          ),
        ),
      );
    });

    test('postStatus posts a new reply and returns the created status', () async {
      final (apiService, mockClient, mockHelper) = setupMockApiService();

      when(
        mockHelper.post(
          "https://example.org/api/v1/statuses",
          body: {
            "status": "Hello, world!",
            "visibility": "public",
            "in_reply_to_id": "replyToId",
            "spoiler_text": "",
          },
          httpClient: mockClient,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id": "1", "created_at": "2025-01-01T00:00:00Z", "visibility": "public", "emoji": [], "content": "<p>Hello, world!</p>", "favourited": false, "bookmarked": false, "reblogged": false, "favourites_count": 0, "reblogs_count": 0, "replies_count": 2, "spoiler_text": "", "account": {"id": "account1", "username": "user1", "acct": "user1", "display_name": "User One", "locked": false, "bot": false, "avatar": "avatar1-url", "header": "header1-url"}}',
          200,
        ),
      );

      final status = await apiService.postStatus(
        "Hello, world!",
        replyToStatus: Status(
          id: "replyToId",
          content: "<p>Reply to this status</p>",
          createdAt: DateTime.parse("2025-01-01T00:00:00Z"),
          favorited: false,
          bookmarked: false,
          reblogged: false,
          favouritesCount: 0,
          reblogsCount: 0,
          repliesCount: 2,
          visibility: StatusVisibility.public,
          customEmojis: [],
          spoilerText: "",
          account: Account(
            id: "account1",
            username: "user1",
            acct: "user1",
            displayName: "User One",
            isLocked: false,
            isBot: false,
          ),
        ),
      );

      expect(status.id, equals("1"));
      expect(status.content, equals("<p>Hello, world!</p>"));
    });
  });
}
