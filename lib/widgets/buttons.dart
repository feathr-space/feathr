import 'package:flutter/material.dart';

/// The [FeatherActionButton] widget renders a button, to be used as a
/// primary button whenever an action is expected from the user.
class FeatherActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonText;

  const FeatherActionButton(
      {required this.onPressed, required this.buttonText, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: const TextStyle(
          fontFamily: "Urbanist",
          fontSize: 18,
        ),
      ),
      style: ElevatedButton.styleFrom(primary: Colors.teal),
    );
  }
}
