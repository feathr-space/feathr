import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:feathr/app.dart';

void main() async {
  // Loading environment variables from file
  await dotenv.load(fileName: ".env");

  // Launching the app!
  runApp(FeathrApp());
}
