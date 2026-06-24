import 'package:flutter/material.dart';

import '../models/todo.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TodoStatus status;

  Color _color(BuildContext context) {
    return switch (status) {
      TodoStatus.pending => Theme.of(context).colorScheme.primary,
      TodoStatus.completed => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
