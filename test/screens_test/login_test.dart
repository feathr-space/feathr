import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/screens/login.dart';

import '../utils.dart';

void main() {
  testWidgets('Login screen is rendered correctly', (
    WidgetTester tester,
  ) async {
    final apiService = getTestApiService();

    await tester.pumpWidget(MaterialApp(home: Login(apiService: apiService)));

    // Expect to find the app's name
    expect(find.text('feathr'), findsOneWidget);
  });
}
