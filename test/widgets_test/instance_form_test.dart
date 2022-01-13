import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feathr/widgets/instance_form.dart';

void main() {
  testWidgets(
    'Instance Form handles invalid data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [InstanceForm(onSuccessfulSubmit: (_) => {})],
            ),
          ),
        ),
      );

      // Initial render
      expect(find.byType(InstanceForm), findsOneWidget);
      expect(find.text('Enter a domain, e.g. mastodon.social'), findsOneWidget);
      expect(find.text('Log in!'), findsOneWidget);
      expect(find.text('This field should not be empty'), findsNothing);
      expect(find.text('Please enter a valid URL'), findsNothing);

      // Attempting to log in without a value
      await tester.tap(find.text('Log in!'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('This field should not be empty'), findsOneWidget);
      expect(find.text('Please enter a valid URL'), findsNothing);

      // Attempt to use an invalid domain
      await tester.enterText(find.byType(TextFormField), 'not a url');
      await tester.tap(find.text('Log in!'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('This field should not be empty'), findsNothing);
      expect(find.text('Please enter a valid URL'), findsOneWidget);
    },
  );

  testWidgets(
    'Instance Form handles valid data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [InstanceForm(onSuccessfulSubmit: (_) => {})],
            ),
          ),
        ),
      );

      // Initial render
      expect(find.byType(InstanceForm), findsOneWidget);
      expect(find.text('Enter a domain, e.g. mastodon.social'), findsOneWidget);
      expect(find.text('Log in!'), findsOneWidget);
      expect(find.text('This field should not be empty'), findsNothing);
      expect(find.text('Please enter a valid URL'), findsNothing);

      // Attempt to use a valid domain
      await tester.enterText(find.byType(TextFormField), 'mastodon.social');
      await tester.tap(find.text('Log in!'));
      expect(find.text('This field should not be empty'), findsNothing);
      expect(find.text('Please enter a valid URL'), findsNothing);
    },
  );
}
