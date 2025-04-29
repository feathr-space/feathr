import 'package:flutter/material.dart';

import 'package:feathr/themes/dark.dart';
import 'package:feathr/themes/light.dart';

import 'package:feathr/services/api.dart';
import 'package:feathr/screens/about.dart';
import 'package:feathr/screens/user.dart';
import 'package:feathr/screens/login.dart';
import 'package:feathr/screens/timeline_tabs.dart';

/// [FeathrApp] is the main, entry widget of the Feathr application.
class FeathrApp extends StatelessWidget {
  FeathrApp({super.key});

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
      onGenerateRoute: (settings) {
        if (settings.name == '/user') {
          final args = settings.arguments as UserScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return User(account: args.account, apiService: apiService);
            },
          );
        }

        return null;
      },
      routes: {
        '/login': (context) => Login(apiService: apiService),
        '/tabs': (context) => TimelineTabs(apiService: apiService),
        '/about': (context) => const About(),
      },
    );
  }
}
