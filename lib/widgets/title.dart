import 'package:flutter/material.dart';

/// The [TitleWidget] widget renders a given string with titling format,
/// ideally to be used where the `feathr` app name needs to be displayed.
class TitleWidget extends StatelessWidget {
  /// String to render within the widget.
  final String title;

  const TitleWidget(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: "Urbanist",
        fontSize: 84,
      ),
    );
  }
}
