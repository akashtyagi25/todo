import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../repository/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider({TodoRepository? repository})
      : _repository = repository ?? TodoRepository();

  final TodoRepository _repository;

  List<Todo> _todos = [];
  bool _isLoading = false;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _repository.getTodos();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmedTitle,
    );

    await _repository.addTodo(todo);
    _todos = [..._todos, todo];
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final updated = _todos[index].copyWith(
      isCompleted: !_todos[index].isCompleted,
    );

    await _repository.updateTodo(updated);
    _todos = [..._todos]..[index] = updated;
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    await _repository.removeTodo(id);
    _todos = _todos.where((todo) => todo.id != id).toList();
    notifyListeners();
  }
}
