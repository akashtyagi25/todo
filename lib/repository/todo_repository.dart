import '../models/todo.dart';
import '../services/todo_local_service.dart';

/// Single source of truth between UI and data layer.
class TodoRepository {
  TodoRepository({TodoLocalService? localService})
      : _localService = localService ?? TodoLocalService.inMemory();

  final TodoLocalService _localService;

  Future<List<Todo>> getTodos(String userId) => _localService.fetchTodos(userId);

  Future<void> addTodo(Todo todo) => _localService.saveTodo(todo);

  Future<void> updateTodo(Todo todo) => _localService.updateTodo(todo);

  Future<void> removeTodo(String id) => _localService.deleteTodo(id);
}
