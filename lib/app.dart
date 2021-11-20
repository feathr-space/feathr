import 'package:flutter/material.dart';

import 'package:feathr/themes/dark.dart';
import 'package:feathr/themes/light.dart';

import 'package:feathr/services/api.dart';
import 'package:feathr/screens/login.dart';
import 'package:feathr/utils/tabs.dart';

/// [FeathrApp] is the main, entry widget of the Feathr application.
class FeathrApp extends StatelessWidget {
  FeathrApp({Key? key}) : super(key: key);

  /// Main instance of the API service to be used across the app.
  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'feathr',
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: ThemeMode.dark,
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(apiService: apiService),
        '/tabs': (context) => const Tabs(),
      },
    );
  }
}
