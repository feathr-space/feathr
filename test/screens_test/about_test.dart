import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/screens/about.dart';

void main() {
  testWidgets('About screen is rendered properly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: About()));

    expect(find.byType(About), findsOneWidget);

    expect(find.text('feathr'), findsOneWidget);
    expect(find.textContaining('feathr'), findsNWidgets(3));
    expect(find.textContaining('free, open source project'), findsOneWidget);
    expect(
      find.textContaining('GNU Affero General Public License'),
      findsOneWidget,
    );
  });
}
