import 'package:flutter_test/flutter_test.dart';

import 'package:todo/models/todo.dart';
import 'package:todo/utils/todo_search.dart';

void main() {
  final sampleTodos = [
    Todo(
      id: '1',
      title: 'Buy groceries',
      description: 'Milk and eggs',
      dueDate: DateTime(2026, 6, 25),
      priority: TodoPriority.high,
      status: TodoStatus.pending,
      createdDate: DateTime(2026, 6, 24),
    ),
    Todo(
      id: '2',
      title: 'Team meeting',
      description: 'Discuss sprint goals',
      dueDate: DateTime(2026, 6, 26),
      priority: TodoPriority.medium,
      status: TodoStatus.completed,
      createdDate: DateTime(2026, 6, 23),
    ),
  ];

  group('TodoSearch', () {
    test('returns all todos when query is empty', () {
      expect(TodoSearch.filter(sampleTodos, ''), sampleTodos);
      expect(TodoSearch.filter(sampleTodos, '   '), sampleTodos);
    });

    test('matches title case-insensitively', () {
      final results = TodoSearch.filter(sampleTodos, 'BUY');
      expect(results, hasLength(1));
      expect(results.first.title, 'Buy groceries');
    });

    test('matches description case-insensitively', () {
      final results = TodoSearch.filter(sampleTodos, 'sprint');
      expect(results, hasLength(1));
      expect(results.first.title, 'Team meeting');
    });

    test('returns empty list when nothing matches', () {
      expect(TodoSearch.filter(sampleTodos, 'vacation'), isEmpty);
    });
  });
}
