import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feather/widgets/buttons.dart';

void main() {
  testWidgets('Action button renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      FeatherActionButton(
        onPressed: () {},
        buttonText: "Click me!"
      )
    );
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Click me!'), findsOneWidget);
  });
}
