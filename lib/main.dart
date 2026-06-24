import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/todo_provider.dart';
import 'repository/todo_repository.dart';
import 'services/hive_service.dart';
import 'services/todo_local_service.dart';
import 'utils/app_error_handler.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppErrorHandler.setup();

    TodoLocalService localService;
    var storageUnavailable = false;

    try {
      await HiveService.init();
      localService = await TodoLocalService.create();
    } catch (error, stack) {
      AppErrorHandler.log(error, stack);
      localService = TodoLocalService.inMemory();
      storageUnavailable = true;
    }

    final repository = TodoRepository(localService: localService);
    final provider = TodoProvider(
      repository: repository,
      storageFallback: storageUnavailable,
    );

    runApp(
      ChangeNotifierProvider.value(
        value: provider,
        child: const TodoApp(),
      ),
    );

    await provider.loadTodos();
  }, AppErrorHandler.log);
}
