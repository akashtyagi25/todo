import '../models/todo.dart';

enum TodoSortOption {
  createdDate,
  dueDate,
  priority,
  alphabetical,
}

extension TodoSortOptionX on TodoSortOption {
  String get label => switch (this) {
        TodoSortOption.createdDate => 'Created Date',
        TodoSortOption.dueDate => 'Due Date',
        TodoSortOption.priority => 'Priority',
        TodoSortOption.alphabetical => 'Alphabetical Order',
      };
}

class TodoSort {
  TodoSort._();

  static int _priorityRank(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.high => 3,
      TodoPriority.medium => 2,
      TodoPriority.low => 1,
    };
  }

  static int compare(Todo a, Todo b, TodoSortOption sortBy) {
    return switch (sortBy) {
      TodoSortOption.createdDate =>
        b.createdDate.compareTo(a.createdDate),
      TodoSortOption.dueDate => a.dueDate.compareTo(b.dueDate),
      TodoSortOption.priority =>
        _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
      TodoSortOption.alphabetical =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
  }

  static List<Todo> apply(List<Todo> todos, TodoSortOption sortBy) {
    final sorted = List<Todo>.from(todos);
    sorted.sort((a, b) => compare(a, b, sortBy));
    return sorted;
  }
}
