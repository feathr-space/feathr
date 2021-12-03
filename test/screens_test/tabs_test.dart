import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/screens/timeline_tabs.dart';

import '../utils.dart';

void main() {
  testWidgets('TimelineTabs wrapper has three tabs',
      (WidgetTester tester) async {
    final apiService = getTestApiService();
    await tester.pumpWidget(MaterialApp(
      home: TimelineTabs(
        apiService: apiService,
      ),
    ));

    // Expect to find our Tabbed view
    expect(find.byType(TimelineTabs), findsOneWidget);

    // Expect to find three tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('Fedi'), findsOneWidget);
  });
}
