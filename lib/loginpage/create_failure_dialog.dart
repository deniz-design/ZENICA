import 'package:flutter/material.dart';

class CreateFailureDialog extends StatelessWidget {
  const CreateFailureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account Creation Failed'),
      content: const Text('Passwords do not match or the account already exists'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
