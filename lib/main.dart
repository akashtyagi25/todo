import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/theme_provider.dart';
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
    final todoProvider = TodoProvider(
      repository: repository,
      storageFallback: storageUnavailable,
    );
    final themeProvider = ThemeProvider();
    await themeProvider.load();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: todoProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const TodoApp(),
      ),
    );

    await todoProvider.loadTodos();
  }, AppErrorHandler.log);
}
