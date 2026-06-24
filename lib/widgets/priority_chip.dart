import 'package:flutter/material.dart';

import '../models/todo.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TodoPriority priority;

  Color _color(BuildContext context) {
    return switch (priority) {
      TodoPriority.low => Colors.green,
      TodoPriority.medium => Colors.orange,
      TodoPriority.high => Colors.red,
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
        priority.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
