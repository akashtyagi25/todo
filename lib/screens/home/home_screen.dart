import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/todo_filter.dart';
import '../../widgets/todo_filter_bar.dart';
import '../../widgets/todo_list_item.dart';
import '../../widgets/todo_search_bar.dart';
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

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _emptyResultsMessage(TodoProvider provider) {
    if (provider.isSearching && provider.isFiltering) {
      return 'No todos match your search and "${provider.activeFilter.label}" filter';
    }
    if (provider.isSearching) {
      return 'No todos match "${provider.searchQuery}"';
    }
    return 'No ${provider.activeFilter.label.toLowerCase()} tasks';
  }

  Widget _buildTodoList(BuildContext context, List<Todo> todos) {
    final pendingTodos =
        todos.where((todo) => todo.status == TodoStatus.pending).toList();
    final completedTodos =
        todos.where((todo) => todo.status == TodoStatus.completed).toList();

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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TodoSearchBar(),
              const SizedBox(height: 4),
              const TodoFilterBar(),
              const SizedBox(height: 8),
              Expanded(
                child: Builder(
                  builder: (context) {
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.filteredTodos.isEmpty) {
                      return _buildEmptyState(
                        context,
                        icon: provider.isSearching
                            ? Icons.search_off_outlined
                            : Icons.filter_alt_off_outlined,
                        message: _emptyResultsMessage(provider),
                      );
                    }

                    return _buildTodoList(context, provider.filteredTodos);
                  },
                ),
              ),
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
