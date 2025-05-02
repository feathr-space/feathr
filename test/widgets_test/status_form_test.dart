import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:feathr/widgets/status_form.dart';
import 'package:feathr/data/status.dart';
import 'package:feathr/data/account.dart';

import '../utils.dart';

void main() {
  testWidgets('Status Form handles invalid data', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusForm(
                apiService: getTestApiService(),
                onSuccessfulSubmit: (_) => {},
              ),
            ],
          ),
        ),
      ),
    );

    // Initial render
    expect(find.byType(StatusForm), findsOneWidget);
    expect(find.text('What\'s on your mind?'), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
    expect(find.text('This field should not be empty'), findsNothing);
    expect(find.text('Content warning (optional)'), findsOneWidget);

    // Attempting to post without a value
    await tester.tap(find.text('Post'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('This field should not be empty'), findsOneWidget);
  });

  testWidgets('Status Form handles content warning input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusForm(
                apiService: getTestApiService(),
                onSuccessfulSubmit: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Verify content warning field exists
    expect(find.text('Content warning (optional)'), findsOneWidget);

    // Enter content warning text
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Content warning (optional)'),
      'Test warning',
    );
    await tester.pump();

    // Verify the text was entered
    expect(find.text('Test warning'), findsOneWidget);
  });

  testWidgets('Status Form handles visibility selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusForm(
                apiService: getTestApiService(),
                onSuccessfulSubmit: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Verify default visibility is public (using first instance which is the selected value)
    expect(find.text('Public').first, findsOneWidget);

    // Open dropdown
    await tester.tap(find.text('Public').first);
    await tester.pumpAndSettle();

    // Verify all visibility options exist
    expect(find.text('Public'), findsWidgets);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Unlisted'), findsOneWidget);

    // Select private visibility (using last instance which is in the dropdown)
    await tester.tap(find.text('Private'));
    await tester.pumpAndSettle();

    // Verify selection changed (now only one instance exists)
    expect(find.text('Private'), findsOneWidget);
  });

  testWidgets('Status Form handles reply to status', (
    WidgetTester tester,
  ) async {
    final testAccount = Account(
      id: '1',
      username: 'testuser',
      displayName: 'Test User',
      acct: 'testuser',
      isLocked: false,
      isBot: false,
    );

    final replyToStatus = Status(
      id: '1',
      content: 'Original status',
      account: testAccount,
      createdAt: DateTime.now(),
      visibility: StatusVisibility.public,
      repliesCount: 0,
      reblogsCount: 0,
      favouritesCount: 0,
      favorited: false,
      reblogged: false,
      bookmarked: false,
      spoilerText: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusForm(
                apiService: getTestApiService(),
                onSuccessfulSubmit: () {},
                replyToStatus: replyToStatus,
              ),
            ],
          ),
        ),
      ),
    );

    // Verify reply text is shown
    expect(find.text('Replying to @testuser'), findsOneWidget);

    // Verify initial text contains mention
    final textField = find.byType(TextFormField).first;
    final TextFormField textFormField = tester.widget(textField);
    expect(textFormField.controller!.text, '@testuser ');
  });
}
