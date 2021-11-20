import 'package:flutter/material.dart';

import 'package:feathr/themes/dark.dart';
import 'package:feathr/themes/light.dart';

import 'package:feathr/utils/tabs.dart';

/// [FeathrApp] is the main, entry widget of the Feathr application.
class FeathrApp extends StatelessWidget {
  const FeathrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'feathr',
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: ThemeMode.dark,
      home: const Tabs(),
    );
  }
}
