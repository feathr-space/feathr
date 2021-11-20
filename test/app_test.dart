import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/app.dart';
import 'package:feathr/utils/tabs.dart';
import 'package:feathr/screens/home.dart';

void main() {
  testWidgets('Main view has three tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FeathrApp());

    // Expect to find our Tabbed view
    expect(find.byType(Tabs), findsOneWidget);

    // Expect to find three tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('Fedi'), findsOneWidget);

    // By default, the Home tab will be displayed
    expect(find.byType(Home), findsOneWidget);
    expect(find.text('Home coming soon!'), findsOneWidget);
    expect(find.text('Local coming soon!'), findsNothing);
    expect(find.text('Fedi coming soon!'), findsNothing);
  });
}
