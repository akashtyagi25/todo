import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_spacing.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/todo_filter.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_loading_view.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/todo_empty_state.dart';
import '../../widgets/todo_filter_bar.dart';
import '../../widgets/todo_list_item.dart';
import '../../widgets/todo_search_bar.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/todo_sort_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _deleteTodo(BuildContext context, Todo todo) async {
    final result = await context.read<TodoProvider>().deleteTodo(todo.id);

    if (!context.mounted) return;

    if (!result.success) {
      AppSnackbar.error(
        context,
        result.errorMessage ?? 'Unable to delete the task.',
      );
      return;
    }

    AppSnackbar.success(context, '"${todo.title}" deleted');
  }

  Future<void> _toggleStatus(BuildContext context, Todo todo) async {
    final provider = context.read<TodoProvider>();
    final result = todo.isCompleted
        ? await provider.reopenTodo(todo.id)
        : await provider.completeTodo(todo.id);

    if (!context.mounted) return;

    if (!result.success) {
      AppSnackbar.error(
        context,
        result.errorMessage ?? 'Unable to update task status.',
      );
      return;
    }

    if (todo.isCompleted) {
      AppSnackbar.info(context, '"${todo.title}" marked as pending');
    } else {
      AppSnackbar.success(context, '"${todo.title}" marked as completed');
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

  Widget _buildErrorBanner(BuildContext context, TodoProvider provider) {
    final message = provider.errorMessage;
    if (message == null) return const SizedBox.shrink();

    return AppErrorBanner(
      message: message,
      onRetry: () => provider.loadTodos(),
      onDismiss: provider.clearError,
    );
  }

  Widget _buildNoTasksEmptyState(BuildContext context, TodoProvider provider) {
    return ResponsiveContent(
      child: TodoEmptyState(
        icon: provider.hasError
            ? Icons.error_outline
            : Icons.task_alt_outlined,
        title: provider.hasError
            ? 'Unable to load tasks'
            : AppConstants.emptyTasksTitle,
        subtitle: provider.hasError
            ? provider.errorMessage
            : AppConstants.emptyTasksSubtitle,
        actionLabel: provider.hasError ? 'Retry' : 'Create Task',
        onAction: provider.hasError
            ? () => provider.loadTodos()
            : () => Navigator.pushNamed(context, AppRoutes.addTodo),
      ),
    );
  }

  Widget _buildNoResultsEmptyState(BuildContext context, TodoProvider provider) {
    return ResponsiveContent(
      child: TodoEmptyState(
        icon: provider.isSearching
            ? Icons.search_off_outlined
            : Icons.filter_alt_off_outlined,
        title: _emptyResultsMessage(provider),
        subtitle: provider.isSearching || provider.isFiltering
            ? 'Try adjusting your search or filter.'
            : null,
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, List<Todo> todos) {
    return ResponsiveContent(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoListItem(
            todo: todo,
            onToggle: () => _toggleStatus(context, todo),
            onEdit: () => Navigator.pushNamed(
              context,
              AppRoutes.editTodo,
              arguments: todo.id,
            ),
            onDelete: () => _deleteTodo(context, todo),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            actions: const [
              ThemeToggleButton(),
              TodoSortButton(),
              SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: _buildBody(context, provider),
          floatingActionButton: provider.todos.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.addTodo),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Todo'),
                ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TodoProvider provider) {
    if (provider.isLoading) {
      return const AppLoadingView();
    }

    if (provider.todos.isEmpty) {
      return Column(
        children: [
          _buildErrorBanner(context, provider),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: const ValueKey('empty-tasks'),
                child: _buildNoTasksEmptyState(context, provider),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildErrorBanner(context, provider),
        const ResponsiveContent(child: TodoSearchBar()),
        const SizedBox(height: AppSpacing.xs),
        const ResponsiveContent(child: TodoFilterBar()),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: provider.filteredTodos.isEmpty
                ? KeyedSubtree(
                    key: const ValueKey('no-results'),
                    child: _buildNoResultsEmptyState(context, provider),
                  )
                : KeyedSubtree(
                    key: const ValueKey('todo-list'),
                    child: _buildTodoList(context, provider.filteredTodos),
                  ),
          ),
        ),
      ],
    );
  }
}
