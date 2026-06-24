import 'package:hive/hive.dart';

import '../models/todo.dart';
import 'hive_service.dart';

/// Handles low-level data operations using Hive local storage.
class TodoLocalService {
  TodoLocalService._({Box<Todo>? box, List<Todo>? memoryTodos})
      : _box = box,
        _memoryTodos = memoryTodos ?? <Todo>[];

  final Box<Todo>? _box;
  final List<Todo> _memoryTodos;

  bool get _usesHive => _box != null;

  static Future<TodoLocalService> create() async {
    final box = await HiveService.openTodosBox();
    return TodoLocalService._(box: box);
  }

  factory TodoLocalService.inMemory() {
    return TodoLocalService._(memoryTodos: <Todo>[]);
  }

  Future<List<Todo>> fetchTodos() async {
    final box = _box;
    if (box != null) {
      return box.values.toList();
    }
    return List<Todo>.from(_memoryTodos);
  }

  Future<void> saveTodo(Todo todo) async {
    final box = _box;
    if (box != null) {
      await box.put(todo.id, todo);
      return;
    }
    _memoryTodos.add(todo);
  }

  Future<void> updateTodo(Todo todo) async {
    final box = _box;
    if (box != null) {
      await box.put(todo.id, todo);
      return;
    }

    final index = _memoryTodos.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      _memoryTodos[index] = todo;
    }
  }

  Future<void> deleteTodo(String id) async {
    final box = _box;
    if (box != null) {
      await box.delete(id);
      return;
    }
    _memoryTodos.removeWhere((todo) => todo.id == id);
  }
}
