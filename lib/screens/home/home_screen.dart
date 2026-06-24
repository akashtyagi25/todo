import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/todo_filter.dart';
import '../../widgets/todo_empty_state.dart';
import '../../widgets/todo_filter_bar.dart';
import '../../widgets/todo_list_item.dart';
import '../../widgets/todo_search_bar.dart';
import '../../widgets/todo_section_header.dart';
import '../../widgets/todo_sort_button.dart';

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

  String _emptyResultsMessage(TodoProvider provider) {
    if (provider.isSearching && provider.isFiltering) {
      return 'No tasks match your search and "${provider.activeFilter.label}" filter.';
    }
    if (provider.isSearching) {
      return 'No tasks match "${provider.searchQuery}".';
    }
    return 'No ${provider.activeFilter.label.toLowerCase()} tasks found.';
  }

  Widget _buildNoTasksEmptyState(BuildContext context) {
    return TodoEmptyState(
      icon: Icons.task_alt_outlined,
      title: AppConstants.emptyTasksTitle,
      subtitle: AppConstants.emptyTasksSubtitle,
      actionLabel: 'Create Task',
      onAction: () => Navigator.pushNamed(context, AppRoutes.addTodo),
    );
  }

  Widget _buildNoResultsEmptyState(BuildContext context, TodoProvider provider) {
    return TodoEmptyState(
      icon: provider.isSearching
          ? Icons.search_off_outlined
          : Icons.filter_alt_off_outlined,
      title: _emptyResultsMessage(provider),
      subtitle: provider.isSearching || provider.isFiltering
          ? 'Try adjusting your search or filter.'
          : null,
    );
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
        actions: const [
          TodoSortButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.todos.isEmpty) {
            return _buildNoTasksEmptyState(context);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TodoSearchBar(),
              const SizedBox(height: 4),
              const TodoFilterBar(),
              const SizedBox(height: 8),
              Expanded(
                child: provider.filteredTodos.isEmpty
                    ? _buildNoResultsEmptyState(context, provider)
                    : _buildTodoList(context, provider.filteredTodos),
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
