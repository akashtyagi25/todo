import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/result/operation_result.dart';
import '../models/todo.dart';
import '../repository/todo_repository.dart';
import '../utils/error_message.dart';
import '../utils/todo_filter.dart';
import '../utils/todo_search.dart';
import '../utils/todo_sort.dart';
import '../utils/todo_validator.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider({
    TodoRepository? repository,
    bool storageFallback = false,
    String? userId,
  })  : _repository = repository ?? TodoRepository(),
        _storageFallback = storageFallback,
        _userId = userId,
        _errorMessage = storageFallback
            ? 'Storage is unavailable. Tasks may not persist after restart.'
            : null;

  final TodoRepository _repository;
  final bool _storageFallback;
  final String? _userId;

  String? get userId => _userId;

  List<Todo> _todos = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';
  TodoFilterOption _activeFilter = TodoFilterOption.all;
  TodoSortOption _activeSort = TodoSortOption.createdDate;

  List<Todo> get todos => List.unmodifiable(_todos);
  List<Todo> get filteredTodos {
    final filtered = TodoFilter.apply(_todos, _activeFilter);
    final searched = TodoSearch.filter(filtered, _searchQuery);
    return TodoSort.apply(searched, _activeSort);
  }

  String get searchQuery => _searchQuery;
  TodoFilterOption get activeFilter => _activeFilter;
  TodoSortOption get activeSort => _activeSort;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isSearching => _searchQuery.trim().isNotEmpty;
  bool get isFiltering => _activeFilter != TodoFilterOption.all;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _errorMessage = ErrorMessage.from(error);
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    setSearchQuery('');
  }

  void setFilter(TodoFilterOption filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  void setSort(TodoSortOption sort) {
    if (_activeSort == sort) return;
    _activeSort = sort;
    notifyListeners();
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
      final uid = _userId;
      if (uid == null) {
        _todos = [];
        return;
      }
      _todos = await _repository.getTodos(uid);
      if (!_storageFallback) {
        _errorMessage = null;
      }
    } catch (error) {
      _todos = [];
      _setError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OperationResult> addTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required TodoPriority priority,
  }) async {
    final titleError = TodoValidator.validateTitle(title);
    if (titleError != null) {
      return OperationResult.failure(titleError);
    }

    final dueDateError = TodoValidator.validateDueDate(dueDate);
    if (dueDateError != null) {
      return OperationResult.failure(dueDateError);
    }

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
        userId: _userId ?? '',
      );

      await _repository.addTodo(todo);
      _todos = [..._todos, todo];
      if (!_storageFallback) _errorMessage = null;
      notifyListeners();
      return const OperationResult.success();
    } catch (error) {
      _setError(error);
      notifyListeners();
      return OperationResult.failure(ErrorMessage.from(error));
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<OperationResult> updateTodo({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required TodoPriority priority,
    required TodoStatus status,
  }) async {
    final titleError = TodoValidator.validateTitle(title);
    if (titleError != null) {
      return OperationResult.failure(titleError);
    }

    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return const OperationResult.failure('Task not found.');
    }

    final original = _todos[index];
    final dueDateError = TodoValidator.validateDueDate(
      dueDate,
      originalDueDate: original.dueDate,
    );
    if (dueDateError != null) {
      return OperationResult.failure(dueDateError);
    }

    _isSaving = true;
    _errorMessage = null;
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
      if (!_storageFallback) _errorMessage = null;
      notifyListeners();
      return const OperationResult.success();
    } catch (error) {
      _setError(error);
      notifyListeners();
      return OperationResult.failure(ErrorMessage.from(error));
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<OperationResult> completeTodo(String id) async {
    return _updateStatus(id, TodoStatus.completed);
  }

  Future<OperationResult> reopenTodo(String id) async {
    return _updateStatus(id, TodoStatus.pending);
  }

  Future<OperationResult> toggleTodo(String id) async {
    final todo = getTodoById(id);
    if (todo == null) {
      return const OperationResult.failure('Task not found.');
    }

    if (todo.status == TodoStatus.pending) {
      return completeTodo(id);
    }
    return reopenTodo(id);
  }

  Future<OperationResult> _updateStatus(String id, TodoStatus status) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return const OperationResult.failure('Task not found.');
    }

    final current = _todos[index];
    if (current.status == status) {
      return const OperationResult.success();
    }

    final updated = current.copyWith(status: status);

    try {
      await _repository.updateTodo(updated);
      _todos = [..._todos]..[index] = updated;
      if (!_storageFallback) _errorMessage = null;
      notifyListeners();
      return const OperationResult.success();
    } catch (error) {
      _setError(error);
      notifyListeners();
      return OperationResult.failure(ErrorMessage.from(error));
    }
  }

  Future<OperationResult> deleteTodo(String id) async {
    try {
      await _repository.removeTodo(id);
      _todos = _todos.where((todo) => todo.id != id).toList();
      if (!_storageFallback) _errorMessage = null;
      notifyListeners();
      return const OperationResult.success();
    } catch (error) {
      _setError(error);
      notifyListeners();
      return OperationResult.failure(ErrorMessage.from(error));
    }
  }
}
