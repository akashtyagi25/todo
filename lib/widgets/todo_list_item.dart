import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../models/todo.dart';
import '../utils/date_formatter.dart';
import 'delete_todo_dialog.dart';
import 'priority_chip.dart';
import 'status_chip.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isCompleted => todo.isCompleted;

  bool get _isOverdue {
    if (_isCompleted) return false;

    final today = DateTime.now();
    final due = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
    final now = DateTime(today.year, today.month, today.day);

    return due.isBefore(now);
  }

  Future<bool> _confirmDelete(BuildContext context) {
    return DeleteTodoDialog.show(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedColor = const Color(0xFF2E7D32);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm - 2,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm - 2,
        ),
        elevation: 0,
        color: _isCompleted
            ? completedColor.withValues(alpha: 0.06)
            : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: _isCompleted
                ? completedColor.withValues(alpha: 0.35)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.md - 4,
              AppSpacing.xs,
              AppSpacing.md - 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: _isCompleted
                          ? 'Mark as pending'
                          : 'Mark as completed',
                      child: Checkbox(
                        value: _isCompleted,
                        onChanged: (_) => onToggle(),
                        activeColor: completedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
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
                              decoration: _isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: _isCompleted
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.45)
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
                                color: _isCompleted
                                    ? theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5)
                                    : theme.colorScheme.onSurfaceVariant,
                                decoration: _isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: _isCompleted ? 0.55 : 1,
                      child: PriorityChip(priority: todo.priority),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit todo',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete todo',
                      onPressed: () async {
                        final confirmed = await _confirmDelete(context);
                        if (confirmed) onDelete();
                      },
                    ),
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
                        valueColor: _isOverdue ? theme.colorScheme.error : null,
                        muted: _isCompleted,
                      ),
                      StatusChip(status: todo.status),
                      if (_isCompleted)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: completedColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Done',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: completedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
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
            decoration: muted && valueColor == null
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
      ],
    );
  }
}
