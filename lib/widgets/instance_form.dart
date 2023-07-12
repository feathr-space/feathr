import 'package:flutter/material.dart';

import 'package:validators/validators.dart';

import 'package:feathr/widgets/buttons.dart';

/// [InstanceForm] is a form widget that requests the user for a domain
/// (text input) that would be used as the base URL for API calls
class InstanceForm extends StatefulWidget {
  /// A function that takes a string (the instance URL) and performs an action,
  /// to be called when the user submits a valid input.
  final Function(String) onSuccessfulSubmit;

  const InstanceForm({
    required this.onSuccessfulSubmit,
    Key? key,
  }) : super(key: key);

  @override
  InstanceFormState createState() {
    return InstanceFormState();
  }
}

/// The [InstanceFormState] class wraps up logic and state for
/// the [InstanceForm] screen.
class InstanceFormState extends State<InstanceForm> {
  /// Global key that uniquely identifies this form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the `instance` text field, to preserve and access the
  /// value set on the input field on this class.
  final instanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              helperText: "Enter a domain, e.g. mastodon.social",
            ),
            controller: instanceController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field should not be empty';
              }

              if (!isURL(value)) {
                return "Please enter a valid URL";
              }

              return null;
            },
          ),
          FeathrActionButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Unfocusing the keyboard and the dialog box
                Navigator.of(context).pop();

                // Calling the success function with the final value of the
                // `instance` text field
                widget.onSuccessfulSubmit(instanceController.text);
              }
            },
            buttonText: "Log in!",
          ),
        ],
      ),
    );
  }
}
