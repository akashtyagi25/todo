import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: backgroundColor ?? colorScheme.inverseSurface,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: colorScheme.onInverseSurface,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colorScheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
    );
  }

  static void error(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: colorScheme.error,
    );
  }
}
