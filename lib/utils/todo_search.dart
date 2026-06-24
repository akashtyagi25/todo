import '../models/todo.dart';

class TodoSearch {
  TodoSearch._();

  static bool matches(Todo todo, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return todo.title.toLowerCase().contains(normalized) ||
        todo.description.toLowerCase().contains(normalized);
  }

  static List<Todo> filter(List<Todo> todos, String query) {
    return todos.where((todo) => matches(todo, query)).toList();
  }
}
