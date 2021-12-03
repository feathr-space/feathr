import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/data/status.dart';

void main() {
  testWidgets(
    'Status is created properly from Json',
    (WidgetTester tester) async {
      Map<String, dynamic> data = {
        "id": "11223344",
        "content": "<p>I am a toot!</p>",
        "account": {
          "id": "this is an id",
          "username": "username123",
          "display_name": "user display name",
          "locked": false,
          "bot": true,
          "avatar": "avatar-url",
          "header": "header-url",
        },
      };

      final status = Status.fromJson(data);
      expect(status.id, equals("11223344"));
      expect(status.content, equals("<p>I am a toot!</p>"));
      expect(status.account.id, equals("this is an id"));
      expect(status.account.username, equals("username123"));
      expect(status.account.displayName, equals("user display name"));
      expect(status.account.isLocked, isFalse);
      expect(status.account.isBot, isTrue);
      expect(status.account.avatarUrl, equals("avatar-url"));
      expect(status.account.headerUrl, equals("header-url"));
    },
  );
}
