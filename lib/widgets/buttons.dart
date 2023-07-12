import 'package:flutter/material.dart';

/// The [FeathrActionButton] widget renders a button, to be used as a
/// primary button whenever an action is expected from the user.
class FeathrActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonText;

  const FeathrActionButton(
      {required this.onPressed, required this.buttonText, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontFamily: "Urbanist",
          fontSize: 18,
        ),
      ),
    );
  }
}
