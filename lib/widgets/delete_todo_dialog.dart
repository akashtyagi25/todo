import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../models/todo.dart';

class DeleteTodoDialog {
  DeleteTodoDialog._();

  static Future<bool> show(BuildContext context, Todo todo) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 28),
          title: const Text('Delete Todo'),
          content: Text(
            'Are you sure you want to delete "${todo.title}"? '
            'This action cannot be undone.',
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
