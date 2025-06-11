import 'package:feathr/data/account.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feathr/widgets/drawer.dart';

void main() {
  testWidgets('Drawer header renders properly', (WidgetTester tester) async {
    final Account account = Account(
      id: '12345678',
      username: 'username',
      acct: 'username',
      displayName: 'display name',
      isBot: false,
      isLocked: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Drawer(child: FeathrDrawerHeader(account: account)),
      ),
    );
    expect(find.text('username'), findsOneWidget);
    expect(find.text('display name'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
    expect(find.byType(DecorationImage), findsNothing);
    expect(find.byType(NetworkImage), findsNothing);
  });

  testWidgets('Drawer header uses default color when headerUrl is null', (
    WidgetTester tester,
  ) async {
    final Account account = Account(
      id: '12345678',
      username: 'username',
      acct: 'username',
      displayName: 'display name',
      isBot: false,
      isLocked: false,
      headerUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Drawer(child: FeathrDrawerHeader(account: account)),
      ),
    );

    final userAccountsDrawerHeader = tester.widget<UserAccountsDrawerHeader>(
      find.byType(UserAccountsDrawerHeader),
    );
    final BoxDecoration? decoration =
        userAccountsDrawerHeader.decoration as BoxDecoration?;

    expect(decoration?.color, Colors.teal);
    expect(decoration?.image, isNull);
  });
}
