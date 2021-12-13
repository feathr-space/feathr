import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/utils/messages.dart';

void main() {
  testWidgets('Messages pop up properly', (WidgetTester tester) async {
    GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: key,
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                showSnackBar(key.currentContext!, "I am a message!");
              },
              child: const Text("press me"),
            ),
          ),
        ),
      ),
    );

    expect(find.text("I am a message!"), findsNothing);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text("I am a message!"), findsOneWidget);
  });
}
