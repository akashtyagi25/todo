import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../utils/date_formatter.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TodoPriority _priority = TodoPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<TodoProvider>().addTodo(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          priority: _priority,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Due Date'),
              subtitle: Text(DateFormatter.format(_dueDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDueDate,
            ),
            const Divider(),
            const SizedBox(height: 8),
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
              onSelectionChanged: (selection) {
                setState(() => _priority = selection.first);
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveTodo,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Save Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
