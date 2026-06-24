import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/todo.dart';

/// Handles low-level data operations using local device storage.
class TodoLocalService {
  TodoLocalService._(this._prefs, this._memoryTodos);

  final SharedPreferences? _prefs;
  final List<Todo>? _memoryTodos;

  static Future<TodoLocalService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TodoLocalService._(prefs, null);
  }

  factory TodoLocalService.inMemory() {
    return TodoLocalService._(null, []);
  }

  Future<List<Todo>> fetchTodos() async {
    if (_memoryTodos != null) {
      return List.from(_memoryTodos!);
    }

    final stored = _prefs!.getStringList(AppConstants.todosStorageKey) ?? [];
    return stored.map((item) => Todo.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveTodo(Todo todo) async {
    final todos = await fetchTodos()..add(todo);
    await _persist(todos);
  }

  Future<void> updateTodo(Todo todo) async {
    final todos = await fetchTodos();
    final index = todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) return;

    todos[index] = todo;
    await _persist(todos);
  }

  Future<void> deleteTodo(String id) async {
    final todos = await fetchTodos()..removeWhere((todo) => todo.id == id);
    await _persist(todos);
  }

  Future<void> _persist(List<Todo> todos) async {
    if (_memoryTodos != null) {
      _memoryTodos!
        ..clear()
        ..addAll(todos);
      return;
    }

    final encoded = todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await _prefs!.setStringList(AppConstants.todosStorageKey, encoded);
  }
}
