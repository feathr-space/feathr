import 'package:feathr/widgets/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/screens/user.dart';

import '../utils.dart';

void main() {
  testWidgets('User screen displays user information', (
    WidgetTester tester,
  ) async {
    final apiService = getTestApiService();
    final account = apiService.currentAccount!;

    await tester.pumpWidget(
      MaterialApp(
        home: User(account: account, apiService: apiService),
      ),
    );

    // Expect to find the user's name
    expect(find.text(account.displayName), findsOneWidget);

    // Expect to find the user's acct
    expect(find.text(account.acct), findsOneWidget);

    // Expect to find a Timeline widget
    expect(find.byType(Timeline), findsOneWidget);
  });
}
