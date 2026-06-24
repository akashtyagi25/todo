import '../models/todo.dart';

/// Handles low-level data operations (local storage, API, etc.).
class TodoLocalService {
  Future<List<Todo>> fetchTodos() async {
    return const [];
  }

  Future<void> saveTodo(Todo todo) async {}

  Future<void> deleteTodo(String id) async {}
}
