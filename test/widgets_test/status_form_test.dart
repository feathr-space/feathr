import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feathr/widgets/status_form.dart';

import '../utils.dart';

void main() {
  testWidgets(
    'Status Form handles invalid data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusForm(
                    apiService: getTestApiService(),
                    onSuccessfulSubmit: (_) => {})
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
    },
  );
}
