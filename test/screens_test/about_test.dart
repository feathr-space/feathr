import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/screens/about.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('About screen is rendered properly', (WidgetTester tester) async {
    // Mocking the package info
    PackageInfo.setMockInitialValues(
      appName: 'feathr',
      packageName: 'space.feathr.app',
      version: '1.2.3',
      buildNumber: '1',
      buildSignature: 'testbuild',
    );

    await tester.pumpWidget(const MaterialApp(home: About()));

    expect(find.byType(About), findsOneWidget);

    expect(find.text('feathr'), findsOneWidget);
    expect(find.textContaining('feathr'), findsNWidgets(3));
    expect(find.textContaining('free, open source project'), findsOneWidget);
    expect(
      find.textContaining('GNU Affero General Public License'),
      findsOneWidget,
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('Version 1.2.3 (build: 1)'), findsOneWidget);
  });
}
