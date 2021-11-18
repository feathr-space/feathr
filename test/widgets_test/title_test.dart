import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:feather/widgets/title.dart';

void main() {
  testWidgets('Title widget renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        child: TitleWidget("I am a title!"),
        textDirection: TextDirection.ltr,
      )
    );
    expect(find.byType(Text), findsOneWidget);
    expect(find.text('I am a title!'), findsOneWidget);
  });
}
