import 'package:feathr/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/utils/tabs.dart';
import 'package:feathr/screens/home.dart';

void main() {
  testWidgets('Tabs wrapper has three tabs', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Tabs(
        apiService: ApiService(),
      ),
    ));

    // Expect to find our Tabbed view
    expect(find.byType(Tabs), findsOneWidget);

    // Expect to find three tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('Fedi'), findsOneWidget);

    // By default, the Home tab will be displayed
    expect(find.byType(Home), findsOneWidget);
    expect(find.text('Home coming soon!'), findsOneWidget);
    expect(find.text('Local coming soon!'), findsNothing);
    expect(find.text('Fedi coming soon!'), findsNothing);
  });
}
