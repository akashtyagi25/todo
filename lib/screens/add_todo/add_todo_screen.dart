import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../utils/date_formatter.dart';
import '../../utils/todo_validator.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _dueDate;
  TodoPriority _priority = TodoPriority.medium;
  String? _dueDateError;

  @override
  void initState() {
    super.initState();
    _dueDate = DateFormatter.today().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final today = DateFormatter.today();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateError = TodoValidator.validateDueDate(_dueDate);
      });
    }
  }

  Future<void> _saveTodo() async {
    setState(() {
      _dueDateError = TodoValidator.validateDueDate(_dueDate);
    });

    if (!_formKey.currentState!.validate() || _dueDateError != null) return;

    final saved = await context.read<TodoProvider>().addTodo(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          priority: _priority,
        );

    if (!mounted) return;

    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<TodoProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
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
                    : const Text('Save Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
