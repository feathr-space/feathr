import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/data/status.dart';

void main() {
  const Map<String, dynamic> testStatusNoReblog = {
    "id": "11223344",
    "content": "<p>I am a toot!</p>",
    "created_at": "2025-01-01T00:00:00Z",
    "favourited": true,
    "bookmarked": false,
    "reblogged": true,
    "visibility": "public",
    "favourites_count": 1,
    "reblogs_count": 0,
    "replies_count": 0,
    "spoiler_text": "",
    "account": {
      "id": "this is an id",
      "username": "username123",
      "acct": "username123",
      "display_name": "user display name",
      "locked": false,
      "bot": true,
      "avatar": "avatar-url",
      "header": "header-url",
    },
    "reblog": null,
  };

  const Map<String, dynamic> testStatusWithReblog = {
    "id": "11223344",
    "content": "<p>I am a toot!</p>",
    "created_at": "2025-01-01T00:00:00Z",
    "favourited": true,
    "bookmarked": false,
    "reblogged": true,
    "visibility": "public",
    "favourites_count": 1,
    "reblogs_count": 0,
    "replies_count": 0,
    "spoiler_text": "",
    "account": {
      "id": "this is an id",
      "username": "username123",
      "acct": "username123",
      "display_name": "user display name",
      "locked": false,
      "bot": true,
      "avatar": "avatar-url",
      "header": "header-url",
    },
    "reblog": {
      "id": "55667788",
      "content": "<p>I am an internal toot!</p>",
      "created_at": "2025-01-01T00:00:00Z",
      "favourited": false,
      "bookmarked": true,
      "reblogged": false,
      "visibility": "public",
      "favourites_count": 1,
      "replies_count": 0,
      "reblogs_count": 0,
      "spoiler_text": "",
      "account": {
        "id": "this is another id",
        "username": "username456",
        "acct": "username456",
        "display_name": "user456 display name",
        "locked": false,
        "bot": true,
        "avatar": "avatar-url-2",
        "header": "header-url-2",
      },
    },
  };

  testWidgets('Status is created properly from Json (not a reblog)', (
    WidgetTester tester,
  ) async {
    final status = Status.fromJson(testStatusNoReblog);

    expect(status.id, equals("11223344"));
    expect(status.content, equals("<p>I am a toot!</p>"));
    expect(status.createdAt, equals(DateTime.parse("2025-01-01T00:00:00Z")));
    expect(status.favorited, isTrue);
    expect(status.bookmarked, isFalse);
    expect(status.reblogged, isTrue);
    expect(status.favouritesCount, equals(1));
    expect(status.repliesCount, equals(0));
    expect(status.reblogsCount, equals(0));
    expect(status.account.id, equals("this is an id"));
    expect(status.account.username, equals("username123"));
    expect(status.account.displayName, equals("user display name"));
    expect(status.account.isLocked, isFalse);
    expect(status.account.isBot, isTrue);
    expect(status.account.avatarUrl, equals("avatar-url"));
    expect(status.account.headerUrl, equals("header-url"));
    expect(status.reblog, isNull);
  });

  testWidgets('Status is created properly from Json (is a reblog)', (
    WidgetTester tester,
  ) async {
    final status = Status.fromJson(testStatusWithReblog);
    expect(status.id, equals("11223344"));
    expect(status.content, equals("<p>I am a toot!</p>"));
    expect(status.createdAt, equals(DateTime.parse("2025-01-01T00:00:00Z")));
    expect(status.favorited, isTrue);
    expect(status.bookmarked, isFalse);
    expect(status.reblogged, isTrue);
    expect(status.favouritesCount, equals(1));
    expect(status.repliesCount, equals(0));
    expect(status.reblogsCount, equals(0));
    expect(status.account.id, equals("this is an id"));
    expect(status.account.username, equals("username123"));
    expect(status.account.displayName, equals("user display name"));
    expect(status.account.isLocked, isFalse);
    expect(status.account.isBot, isTrue);
    expect(status.account.avatarUrl, equals("avatar-url"));
    expect(status.account.headerUrl, equals("header-url"));
    expect(status.reblog, isNotNull);

    final reblog = status.reblog!;
    expect(reblog.id, equals("55667788"));
    expect(reblog.content, equals("<p>I am an internal toot!</p>"));
    expect(reblog.favorited, isFalse);
    expect(reblog.bookmarked, isTrue);
    expect(reblog.reblogged, isFalse);
    expect(status.favouritesCount, equals(1));
    expect(status.reblogsCount, equals(0));
    expect(reblog.account.id, equals("this is another id"));
    expect(reblog.account.username, equals("username456"));
    expect(reblog.account.displayName, equals("user456 display name"));
    expect(reblog.account.isLocked, isFalse);
    expect(reblog.account.isBot, isTrue);
    expect(reblog.account.avatarUrl, equals("avatar-url-2"));
    expect(reblog.account.headerUrl, equals("header-url-2"));
  });

  testWidgets(
    'Status.getContent returns the expected content (internal if reblog)',
    (WidgetTester tester) async {
      final status_1 = Status.fromJson(testStatusNoReblog);
      expect(status_1.content, equals("<p>I am a toot!</p>"));
      expect(status_1.reblog, isNull);
      expect(status_1.getContent(), equals("<p>I am a toot!</p>"));

      final status_2 = Status.fromJson(testStatusWithReblog);
      expect(status_2.content, equals("<p>I am a toot!</p>"));
      expect(status_2.reblog, isNotNull);
      expect(status_2.reblog!.content, equals("<p>I am an internal toot!</p>"));
      expect(status_2.reblog!.account.acct, equals("username456"));
      expect(
        status_2.getContent(),
        equals("Reblogged from username456: <p>I am an internal toot!</p>"),
      );
    },
  );
}
