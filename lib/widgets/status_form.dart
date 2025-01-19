import 'package:feathr/services/api.dart';
import 'package:flutter/material.dart';

import 'package:feathr/widgets/buttons.dart';

/// [StatusForm] is a form widget that allows the user to compose
/// a new status (text input) and submit it to the server.
class StatusForm extends StatefulWidget {
  /// A function that performs an action, to be called when the user submits
  /// a valid input.
  final Function onSuccessfulSubmit;

  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  const StatusForm({
    required this.apiService,
    required this.onSuccessfulSubmit,
    super.key,
  });

  @override
  StatusFormState createState() {
    return StatusFormState();
  }
}

/// The [StatusFormState] class wraps up logic and state for the
/// [StatusForm] screen.
class StatusFormState extends State<StatusForm> {
  /// Global key that uniquely identifies this form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the `status` text field, to preserve and access the
  /// value set on the input field on this class.
  final statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            helperText: "What's on your mind?",
          ),
          controller: statusController,
          validator: (value) => value == null || value.isEmpty
              ? 'This field should not be empty'
              : null,
        ),
        FeathrActionButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Implement the API call to submit the status
              widget.onSuccessfulSubmit();
            }
          },
          buttonText: 'Post',
        ),
      ]),
    );
  }
}
