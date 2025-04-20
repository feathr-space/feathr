import 'package:feathr/data/status.dart';
import 'package:feathr/services/api.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feathr/widgets/status_card.dart';

import '../utils.dart';

void main() {
  testWidgets(
    'Status Card is rendered properly',
    (WidgetTester tester) async {
      ApiService apiService = getTestApiService();
      Status status = Status(
          id: "12345678",
          createdAt: DateTime(2025, 1, 5, 14, 30, 0),
          content: "<p>This is a toot!</p>",
          account: apiService.currentAccount!,
          favorited: true,
          reblogged: false,
          bookmarked: true,
          favouritesCount: 10,
          reblogsCount: 5,
          repliesCount: 2,
          visibility: StatusVisibility.public);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusCard(
                  status,
                  apiService: apiService,
                ),
              ],
            ),
          ),
        ),
      );

      // Initial render
      expect(find.byType(StatusCard), findsOneWidget);
      expect(find.text('display name'), findsOneWidget);
      expect(find.text('username'), findsOneWidget);
      expect(find.text('This is a toot!'), findsOneWidget);
      expect(
        find.widgetWithIcon(IconButton, FeatherIcons.bookmark),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(IconButton, FeatherIcons.star),
        findsOneWidget,
      );
      expect(
        find.widgetWithIcon(IconButton, FeatherIcons.repeat),
        findsOneWidget,
      );
    },
  );
}
