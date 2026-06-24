import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  height: 1.4,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ],
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                tooltip: 'Dismiss',
              ),
          ],
        ),
      ),
    );
  }
}
