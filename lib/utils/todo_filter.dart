import '../models/todo.dart';

enum TodoFilterOption {
  all,
  pending,
  completed,
  highPriority,
  mediumPriority,
  lowPriority,
}

extension TodoFilterOptionX on TodoFilterOption {
  String get label => switch (this) {
        TodoFilterOption.all => 'All Tasks',
        TodoFilterOption.pending => 'Pending',
        TodoFilterOption.completed => 'Completed',
        TodoFilterOption.highPriority => 'High Priority',
        TodoFilterOption.mediumPriority => 'Medium Priority',
        TodoFilterOption.lowPriority => 'Low Priority',
      };
}

class TodoFilter {
  TodoFilter._();

  static bool matches(Todo todo, TodoFilterOption filter) {
    return switch (filter) {
      TodoFilterOption.all => true,
      TodoFilterOption.pending => todo.status == TodoStatus.pending,
      TodoFilterOption.completed => todo.status == TodoStatus.completed,
      TodoFilterOption.highPriority => todo.priority == TodoPriority.high,
      TodoFilterOption.mediumPriority => todo.priority == TodoPriority.medium,
      TodoFilterOption.lowPriority => todo.priority == TodoPriority.low,
    };
  }

  static List<Todo> apply(List<Todo> todos, TodoFilterOption filter) {
    if (filter == TodoFilterOption.all) return todos;
    return todos.where((todo) => matches(todo, filter)).toList();
  }
}
