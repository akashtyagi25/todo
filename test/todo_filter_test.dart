import 'package:flutter_test/flutter_test.dart';

import 'package:todo/models/todo.dart';
import 'package:todo/utils/todo_filter.dart';

void main() {
  final sampleTodos = [
    Todo(
      id: '1',
      title: 'Urgent fix',
      description: 'Production bug',
      dueDate: DateTime(2026, 6, 25),
      priority: TodoPriority.high,
      status: TodoStatus.pending,
      createdDate: DateTime(2026, 6, 24),
    ),
    Todo(
      id: '2',
      title: 'Weekly report',
      description: 'Send to manager',
      dueDate: DateTime(2026, 6, 26),
      priority: TodoPriority.medium,
      status: TodoStatus.completed,
      createdDate: DateTime(2026, 6, 23),
    ),
    Todo(
      id: '3',
      title: 'Read book',
      description: 'Chapter 1',
      dueDate: DateTime(2026, 6, 27),
      priority: TodoPriority.low,
      status: TodoStatus.pending,
      createdDate: DateTime(2026, 6, 22),
    ),
  ];

  group('TodoFilter', () {
    test('all returns every todo', () {
      expect(
        TodoFilter.apply(sampleTodos, TodoFilterOption.all),
        sampleTodos,
      );
    });

    test('filters by status', () {
      expect(
        TodoFilter.apply(sampleTodos, TodoFilterOption.pending),
        hasLength(2),
      );
      expect(
        TodoFilter.apply(sampleTodos, TodoFilterOption.completed),
        hasLength(1),
      );
    });

    test('filters by priority', () {
      expect(
        TodoFilter.apply(sampleTodos, TodoFilterOption.highPriority),
        hasLength(1),
      );
      expect(
        TodoFilter.apply(sampleTodos, TodoFilterOption.mediumPriority),
        hasLength(1),
      );
      expect(
        TodoFilter.apply(sampleTodos, TodoFilterOption.lowPriority),
        hasLength(1),
      );
    });
  });
}
