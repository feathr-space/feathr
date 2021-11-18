import 'package:flutter/material.dart';

import 'package:feather/themes/dark.dart';
import 'package:feather/themes/light.dart';

import 'package:feather/utils/tabs.dart';

/// [FeatherApp] is the main, entry widget of the Feather application.
class FeatherApp extends StatelessWidget {
  const FeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: ThemeMode.dark,
      home: const Tabs(),
    );
  }
}
