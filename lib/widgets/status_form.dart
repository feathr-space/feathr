import 'package:feathr/services/api.dart';
import 'package:feathr/utils/messages.dart';
import 'package:flutter/material.dart';

import 'package:feathr/data/status.dart';
import 'package:feathr/widgets/buttons.dart';

/// [StatusForm] is a form widget that allows the user to compose
/// a new status (text input) and submit it to the server.
class StatusForm extends StatefulWidget {
  /// A function that performs an action, to be called when the user submits
  /// a valid input.
  final Function onSuccessfulSubmit;

  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  /// Status that is being replied to, if any.
  final Status? replyToStatus;

  const StatusForm({
    required this.apiService,
    required this.onSuccessfulSubmit,
    this.replyToStatus,
    super.key,
  });

  @override
  StatusFormState createState() {
    return StatusFormState();
  }

  /// Displays a dialog box with a form to post a status.
  static void displayStatusFormWindow(
    BuildContext context,
    ApiService apiService, {
    Status? replyToStatus,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Compose a new status",
            textAlign: TextAlign.center,
          ),
          titleTextStyle: const TextStyle(fontSize: 18.0),
          content: StatusForm(
            apiService: apiService,
            replyToStatus: replyToStatus,
            onSuccessfulSubmit: () {
              // Hide the dialog box
              Navigator.of(context).pop();

              // Show a success message
              showSnackBar(context, "Status posted successfully!");
            },
          ),
        );
      },
    );
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

  /// Controller for the `spoilerText` text field, to preserve and access the
  /// value set on the input field on this class.
  final spoilerTextController = TextEditingController();

  /// Selected visibility for the status.
  StatusVisibility selectedVisibility = StatusVisibility.public;

  @override
  Widget build(BuildContext context) {
    if (widget.replyToStatus != null) {
      // If the status is a reply to someone other than the user,
      // set the text field to include the reply-to status.
      if (widget.replyToStatus!.account.id !=
          widget.apiService.currentAccount!.id) {
        // Set the text field to include the reply-to status.
        statusController.text = '@${widget.replyToStatus!.account.acct} ';
      }
    }

    String helperText = "What's on your mind?";
    if (widget.replyToStatus != null) {
      // If the status is a reply, set the helper text to include the
      // reply-to status.
      helperText = "Replying to @${widget.replyToStatus!.account.acct}";
    }

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(helperText: helperText),
            controller: statusController,
            validator: (value) => value == null || value.isEmpty
                ? 'This field should not be empty'
                : null,
          ),
          DropdownButtonFormField<StatusVisibility>(
            value: selectedVisibility,
            decoration: const InputDecoration(helperText: 'Visibility'),
            items: const [
              DropdownMenuItem(
                value: StatusVisibility.public,
                child: Text('Public'),
              ),
              DropdownMenuItem(
                value: StatusVisibility.unlisted,
                child: Text('Unlisted'),
              ),
              DropdownMenuItem(
                value: StatusVisibility.private,
                child: Text('Private'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedVisibility = value!;
              });
            },
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              helperText: "Content warning (optional)",
            ),
            controller: spoilerTextController,
          ),
          FeathrActionButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Hide the button and show a spinner while the status is being
                // submitted

                // Post the status to the server
                try {
                  await widget.apiService.postStatus(
                    statusController.text,
                    replyToStatus: widget.replyToStatus,
                    visibility: selectedVisibility,
                    spoilerText: spoilerTextController.text,
                  );
                } catch (e) {
                  // Show an error message if the status couldn't be posted
                  if (context.mounted) {
                    showSnackBar(context, 'Failed to post status: $e');
                  }

                  return;
                }

                // Post was successful, call the success function!
                widget.onSuccessfulSubmit();
              }
            },
            buttonText: 'Post',
          ),
        ],
      ),
    );
  }
}
