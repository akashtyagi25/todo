import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/todo_provider.dart';
import 'repository/todo_repository.dart';
import 'services/todo_local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localService = await TodoLocalService.create();
  final repository = TodoRepository(localService: localService);

  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(repository: repository)..loadTodos(),
      child: const TodoApp(),
    ),
  );
}
