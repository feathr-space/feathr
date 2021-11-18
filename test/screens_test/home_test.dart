import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feather/screens/home.dart';

void main() {
  testWidgets('Home renders with a temporary message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: Home())
    );
    expect(find.byType(Home), findsOneWidget);
    expect(find.text('Home coming soon!'), findsOneWidget);
  });
}
