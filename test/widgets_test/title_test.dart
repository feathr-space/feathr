import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feathr/widgets/title.dart';

void main() {
  testWidgets('Title widget renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: TitleWidget("I am a title!"),
      ),
    );
    expect(find.byType(Text), findsOneWidget);
    expect(find.text('I am a title!'), findsOneWidget);
  });
}
