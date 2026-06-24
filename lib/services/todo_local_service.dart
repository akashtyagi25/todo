import 'package:hive/hive.dart';

import '../core/errors/app_exception.dart';
import '../models/todo.dart';
import 'hive_service.dart';

/// Handles low-level data operations using Hive local storage.
class TodoLocalService {
  TodoLocalService._({Box<Todo>? box, List<Todo>? memoryTodos})
      : _box = box,
        _memoryTodos = memoryTodos ?? <Todo>[];

  final Box<Todo>? _box;
  final List<Todo> _memoryTodos;

  static Future<TodoLocalService> create() async {
    final box = await HiveService.openTodosBox();
    return TodoLocalService._(box: box);
  }

  factory TodoLocalService.inMemory() {
    return TodoLocalService._(memoryTodos: <Todo>[]);
  }

  Future<List<Todo>> fetchTodos() async {
    try {
      final box = _box;
      if (box != null) {
        return box.values.toList();
      }
      return List<Todo>.from(_memoryTodos);
    } catch (error) {
      throw StorageException('Unable to load tasks.');
    }
  }

  Future<void> saveTodo(Todo todo) async {
    try {
      final box = _box;
      if (box != null) {
        await box.put(todo.id, todo);
        return;
      }
      _memoryTodos.add(todo);
    } catch (error) {
      throw StorageException('Unable to save the task.');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final box = _box;
      if (box != null) {
        await box.put(todo.id, todo);
        return;
      }

      final index = _memoryTodos.indexWhere((item) => item.id == todo.id);
      if (index == -1) {
        throw const NotFoundException();
      }
      _memoryTodos[index] = todo;
    } catch (error) {
      if (error is AppException) rethrow;
      throw StorageException('Unable to update the task.');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final box = _box;
      if (box != null) {
        await box.delete(id);
        return;
      }
      _memoryTodos.removeWhere((todo) => todo.id == id);
    } catch (error) {
      throw StorageException('Unable to delete the task.');
    }
  }
}
