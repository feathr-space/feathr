import 'package:flutter/material.dart';

import 'package:feather/screens/home.dart';
import 'package:feather/themes/dark.dart';

void main() {
  runApp(const FeatherApp());
}

class FeatherApp extends StatelessWidget {
  const FeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: darkThemeData,
      home: const Home(title: 'Flutter Demo Home Page'),
    );
  }
}

