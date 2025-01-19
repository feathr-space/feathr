import 'package:flutter/material.dart';

/// The [FeathrActionButton] widget renders a button, to be used as a
/// primary button whenever an action is expected from the user.
class FeathrActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonText;

  const FeathrActionButton(
      {required this.onPressed, required this.buttonText, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontFamily: "Urbanist",
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
