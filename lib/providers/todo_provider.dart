import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../repository/todo_repository.dart';
import '../utils/todo_search.dart';
import '../utils/todo_validator.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider({TodoRepository? repository})
      : _repository = repository ?? TodoRepository();

  final TodoRepository _repository;

  List<Todo> _todos = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _searchQuery = '';

  List<Todo> get todos => List.unmodifiable(_todos);
  List<Todo> get filteredTodos =>
      TodoSearch.filter(_todos, _searchQuery);
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    setSearchQuery('');
  }

  Todo? getTodoById(String id) {
    for (final todo in _todos) {
      if (todo.id == id) return todo;
    }
    return null;
  }

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

  Future<bool> updateTodo({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required TodoPriority priority,
    required TodoStatus status,
  }) async {
    if (TodoValidator.validateTitle(title) != null) return false;

    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return false;

    final original = _todos[index];
    if (TodoValidator.validateDueDate(
          dueDate,
          originalDueDate: original.dueDate,
        ) !=
        null) {
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final updated = original.copyWith(
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        priority: priority,
        status: status,
      );

      await _repository.updateTodo(updated);
      _todos = [..._todos]..[index] = updated;
      notifyListeners();
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> completeTodo(String id) async {
    await _updateStatus(id, TodoStatus.completed);
  }

  Future<void> reopenTodo(String id) async {
    await _updateStatus(id, TodoStatus.pending);
  }

  Future<void> toggleTodo(String id) async {
    final todo = getTodoById(id);
    if (todo == null) return;

    if (todo.status == TodoStatus.pending) {
      await completeTodo(id);
    } else {
      await reopenTodo(id);
    }
  }

  Future<void> _updateStatus(String id, TodoStatus status) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final current = _todos[index];
    if (current.status == status) return;

    final updated = current.copyWith(status: status);

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
