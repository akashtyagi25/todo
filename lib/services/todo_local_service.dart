import '../models/todo.dart';

/// Handles low-level data operations (local storage, API, etc.).
class TodoLocalService {
  final List<Todo> _todos = [];

  Future<List<Todo>> fetchTodos() async => List.from(_todos);

  Future<void> saveTodo(Todo todo) async {
    _todos.add(todo);
  }

  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
  }
}
