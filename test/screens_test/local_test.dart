import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feather/screens/local.dart';

void main() {
  testWidgets('Local renders with a temporary message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: Local())
    );
    expect(find.byType(Local), findsOneWidget);
    expect(find.text('Local coming soon!'), findsOneWidget);
  });
}
