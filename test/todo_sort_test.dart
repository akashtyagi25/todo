import 'package:flutter_test/flutter_test.dart';

import 'package:todo/models/todo.dart';
import 'package:todo/utils/todo_sort.dart';

void main() {
  Todo buildTodo({
    required String id,
    required String title,
    required DateTime createdDate,
    required DateTime dueDate,
    required TodoPriority priority,
  }) {
    return Todo(
      id: id,
      title: title,
      description: '',
      dueDate: dueDate,
      priority: priority,
      status: TodoStatus.pending,
      createdDate: createdDate,
    );
  }

  final todos = [
    buildTodo(
      id: '1',
      title: 'Zebra task',
      createdDate: DateTime(2026, 6, 20),
      dueDate: DateTime(2026, 6, 30),
      priority: TodoPriority.low,
    ),
    buildTodo(
      id: '2',
      title: 'Alpha task',
      createdDate: DateTime(2026, 6, 24),
      dueDate: DateTime(2026, 6, 25),
      priority: TodoPriority.high,
    ),
    buildTodo(
      id: '3',
      title: 'Middle task',
      createdDate: DateTime(2026, 6, 22),
      dueDate: DateTime(2026, 6, 28),
      priority: TodoPriority.medium,
    ),
  ];

  group('TodoSort', () {
    test('sorts by created date newest first', () {
      final sorted = TodoSort.apply(todos, TodoSortOption.createdDate);
      expect(sorted.map((todo) => todo.id).toList(), ['2', '3', '1']);
    });

    test('sorts by due date earliest first', () {
      final sorted = TodoSort.apply(todos, TodoSortOption.dueDate);
      expect(sorted.map((todo) => todo.id).toList(), ['2', '3', '1']);
    });

    test('sorts by priority high to low', () {
      final sorted = TodoSort.apply(todos, TodoSortOption.priority);
      expect(sorted.map((todo) => todo.id).toList(), ['2', '3', '1']);
    });

    test('sorts alphabetically by title', () {
      final sorted = TodoSort.apply(todos, TodoSortOption.alphabetical);
      expect(sorted.map((todo) => todo.title).toList(), [
        'Alpha task',
        'Middle task',
        'Zebra task',
      ]);
    });
  });
}
