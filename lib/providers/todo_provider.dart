import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../repository/todo_repository.dart';
import '../utils/todo_validator.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider({TodoRepository? repository})
      : _repository = repository ?? TodoRepository();

  final TodoRepository _repository;

  List<Todo> _todos = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

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

  Future<bool> addTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required TodoPriority priority,
  }) async {
    if (TodoValidator.validateTitle(title) != null) return false;
    if (TodoValidator.validateDueDate(dueDate) != null) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final todo = Todo(
        id: now.millisecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        priority: priority,
        status: TodoStatus.pending,
        createdDate: now,
      );

      await _repository.addTodo(todo);
      _todos = [..._todos, todo];
      notifyListeners();
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final current = _todos[index];
    final updated = current.copyWith(
      status: current.status == TodoStatus.pending
          ? TodoStatus.completed
          : TodoStatus.pending,
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
