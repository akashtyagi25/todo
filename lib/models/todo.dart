enum TodoPriority { low, medium, high }

enum TodoStatus { pending, completed }

extension TodoPriorityX on TodoPriority {
  String get label => switch (this) {
        TodoPriority.low => 'Low',
        TodoPriority.medium => 'Medium',
        TodoPriority.high => 'High',
      };

  static TodoPriority fromString(String value) {
    return TodoPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => TodoPriority.medium,
    );
  }
}

extension TodoStatusX on TodoStatus {
  String get label => switch (this) {
        TodoStatus.pending => 'Pending',
        TodoStatus.completed => 'Completed',
      };

  bool get isCompleted => this == TodoStatus.completed;

  static TodoStatus fromString(String value) {
    return TodoStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TodoStatus.pending,
    );
  }
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

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: TodoPriorityX.fromString(json['priority'] as String),
      status: TodoStatusX.fromString(json['status'] as String),
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'createdDate': createdDate.toIso8601String(),
    };
  }

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
