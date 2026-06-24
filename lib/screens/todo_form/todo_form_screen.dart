import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../utils/date_formatter.dart';
import '../../utils/todo_validator.dart';

class TodoFormScreen extends StatefulWidget {
  const TodoFormScreen({super.key, this.todoId});

  final String? todoId;

  bool get isEditing => todoId != null;

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _dueDate;
  TodoPriority _priority = TodoPriority.medium;
  TodoStatus _status = TodoStatus.pending;
  DateTime? _originalDueDate;
  String? _dueDateError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _dueDate = DateFormatter.today().add(const Duration(days: 1));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized || !widget.isEditing) return;

    final todo = context.read<TodoProvider>().getTodoById(widget.todoId!);
    if (todo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
    _dueDate = todo.dueDate;
    _originalDueDate = todo.dueDate;
    _priority = todo.priority;
    _status = todo.status;
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime get _minSelectableDate {
    if (widget.isEditing &&
        _originalDueDate != null &&
        DateFormatter.isBeforeToday(_originalDueDate!)) {
      return DateFormatter.dateOnly(_originalDueDate!);
    }
    return DateFormatter.today();
  }

  Future<void> _pickDueDate() async {
    final today = DateFormatter.today();
    final minDate = _minSelectableDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(minDate) ? minDate : _dueDate,
      firstDate: minDate,
      lastDate: today.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateError = TodoValidator.validateDueDate(
          _dueDate,
          originalDueDate: _originalDueDate,
        );
      });
    }
  }

  Future<void> _saveTodo() async {
    setState(() {
      _dueDateError = TodoValidator.validateDueDate(
        _dueDate,
        originalDueDate: _originalDueDate,
      );
    });

    if (!_formKey.currentState!.validate() || _dueDateError != null) return;

    final provider = context.read<TodoProvider>();
    final saved = widget.isEditing
        ? await provider.updateTodo(
            id: widget.todoId!,
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _dueDate,
            priority: _priority,
            status: _status,
          )
        : await provider.addTodo(
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _dueDate,
            priority: _priority,
          );

    if (!mounted) return;

    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Todo updated successfully'
                : 'Todo saved successfully',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<TodoProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Todo' : 'Add Todo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: TodoValidator.validateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task details (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: isSaving ? null : _pickDueDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date *',
                  border: const OutlineInputBorder(),
                  errorText: _dueDateError,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(DateFormatter.format(_dueDate)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TodoPriority>(
              segments: TodoPriority.values
                  .map(
                    (priority) => ButtonSegment(
                      value: priority,
                      label: Text(priority.label),
                    ),
                  )
                  .toList(),
              selected: {_priority},
              onSelectionChanged: isSaving
                  ? null
                  : (selection) {
                      setState(() => _priority = selection.first);
                    },
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 16),
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<TodoStatus>(
                segments: TodoStatus.values
                    .map(
                      (status) => ButtonSegment(
                        value: status,
                        label: Text(status.label),
                      ),
                    )
                    .toList(),
                selected: {_status},
                onSelectionChanged: isSaving
                    ? null
                    : (selection) {
                        setState(() => _status = selection.first);
                      },
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isSaving ? null : _saveTodo,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'Update Todo' : 'Save Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
