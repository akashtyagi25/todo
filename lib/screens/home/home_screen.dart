import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/todo_list_item.dart';
import '../../widgets/todo_section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _deleteTodo(BuildContext context, Todo todo) async {
    await context.read<TodoProvider>().deleteTodo(todo.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${todo.title}" deleted')),
    );
  }

  Future<void> _toggleStatus(BuildContext context, Todo todo) async {
    final provider = context.read<TodoProvider>();

    if (todo.isCompleted) {
      await provider.reopenTodo(todo.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${todo.title}" marked as pending')),
      );
    } else {
      await provider.completeTodo(todo.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${todo.title}" marked as completed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 72,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No todos yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first todo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          final pendingTodos = provider.todos
              .where((todo) => todo.status == TodoStatus.pending)
              .toList();
          final completedTodos = provider.todos
              .where((todo) => todo.status == TodoStatus.completed)
              .toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (pendingTodos.isNotEmpty) ...[
                TodoSectionHeader(
                  title: 'Pending',
                  count: pendingTodos.length,
                  icon: Icons.pending_actions_outlined,
                ),
                ...pendingTodos.map(
                  (todo) => TodoListItem(
                    todo: todo,
                    onToggle: () => _toggleStatus(context, todo),
                    onEdit: () => Navigator.pushNamed(
                      context,
                      AppRoutes.editTodo,
                      arguments: todo.id,
                    ),
                    onDelete: () => _deleteTodo(context, todo),
                  ),
                ),
              ],
              if (completedTodos.isNotEmpty) ...[
                TodoSectionHeader(
                  title: 'Completed',
                  count: completedTodos.length,
                  icon: Icons.task_alt_outlined,
                ),
                ...completedTodos.map(
                  (todo) => TodoListItem(
                    todo: todo,
                    onToggle: () => _toggleStatus(context, todo),
                    onEdit: () => Navigator.pushNamed(
                      context,
                      AppRoutes.editTodo,
                      arguments: todo.id,
                    ),
                    onDelete: () => _deleteTodo(context, todo),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTodo),
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
    );
  }
}
