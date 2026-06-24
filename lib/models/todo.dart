enum TodoPriority { low, medium, high }

enum TodoStatus { pending, completed }

extension TodoPriorityX on TodoPriority {
  String get label => switch (this) {
        TodoPriority.low => 'Low',
        TodoPriority.medium => 'Medium',
        TodoPriority.high => 'High',
      };
}

extension TodoStatusX on TodoStatus {
  String get label => switch (this) {
        TodoStatus.pending => 'Pending',
        TodoStatus.completed => 'Completed',
      };

  bool get isCompleted => this == TodoStatus.completed;
}

class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdDate,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TodoPriority priority;
  final TodoStatus status;
  final DateTime createdDate;

  bool get isCompleted => status.isCompleted;

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? createdDate,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
