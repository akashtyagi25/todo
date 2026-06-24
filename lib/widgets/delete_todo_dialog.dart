import 'package:flutter/material.dart';

import '../models/todo.dart';

class DeleteTodoDialog {
  DeleteTodoDialog._();

  static Future<bool> show(BuildContext context, Todo todo) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: Text(
            'Are you sure you want to delete "${todo.title}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
