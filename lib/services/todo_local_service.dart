import 'package:hive/hive.dart';

import '../models/todo.dart';
import 'hive_service.dart';

/// Handles low-level data operations using Hive local storage.
class TodoLocalService {
  TodoLocalService._(this._box, this._memoryTodos);

  final Box<Todo>? _box;
  final List<Todo>? _memoryTodos;

  static Future<TodoLocalService> create() async {
    final box = await HiveService.openTodosBox();
    return TodoLocalService._(box, null);
  }

  factory TodoLocalService.inMemory() {
    return TodoLocalService._(null, []);
  }

  Future<List<Todo>> fetchTodos() async {
    if (_memoryTodos != null) {
      return List.from(_memoryTodos!);
    }

    return _box!.values.toList();
  }

  Future<void> saveTodo(Todo todo) async {
    if (_memoryTodos != null) {
      _memoryTodos!.add(todo);
      return;
    }

    await _box!.put(todo.id, todo);
  }

  Future<void> updateTodo(Todo todo) async {
    if (_memoryTodos != null) {
      final index = _memoryTodos!.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        _memoryTodos![index] = todo;
      }
      return;
    }

    await _box!.put(todo.id, todo);
  }

  Future<void> deleteTodo(String id) async {
    if (_memoryTodos != null) {
      _memoryTodos!.removeWhere((todo) => todo.id == id);
      return;
    }

    await _box!.delete(id);
  }
}
