import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/screens/fedi.dart';

void main() {
  testWidgets('Fedi renders with a temporary message',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
        const Directionality(textDirection: TextDirection.ltr, child: Fedi()));
    expect(find.byType(Fedi), findsOneWidget);
    expect(find.text('Fedi coming soon!'), findsOneWidget);
  });
}
