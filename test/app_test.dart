import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/app.dart';
import 'package:feathr/screens/login.dart';
import 'package:feathr/screens/timeline_tabs.dart';
import 'package:feathr/widgets/title.dart';

void main() {
  testWidgets('Main view shows log-in', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(FeathrApp());

    // Expect to find our Login view
    expect(find.byType(Login), findsOneWidget);
    expect(find.byType(TimelineTabs), findsNothing);

    // Expect to find the title of the app
    expect(find.byType(TitleWidget), findsOneWidget);
    expect(find.text('feathr'), findsOneWidget);
  });
}
