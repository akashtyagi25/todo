import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../utils/date_formatter.dart';
import 'priority_chip.dart';
import 'status_chip.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  bool get _isOverdue {
    if (todo.isCompleted) return false;

    final today = DateTime.now();
    final due = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
    final now = DateTime(today.year, today.month, today.day);

    return due.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => onToggle(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5)
                                : null,
                          ),
                        ),
                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            todo.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PriorityChip(priority: todo.priority),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Due',
                      value: DateFormatter.format(todo.dueDate),
                      valueColor: _isOverdue ? Colors.red : null,
                    ),
                    StatusChip(status: todo.status),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Created',
                  value: DateFormatter.format(todo.createdDate),
                  muted: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = muted
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(color: textColor),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor ?? textColor,
            fontWeight: valueColor != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
