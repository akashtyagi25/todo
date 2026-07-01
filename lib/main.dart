import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/theme_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/auth_provider.dart';
import 'repository/todo_repository.dart';
import 'repository/auth_repository.dart';
import 'services/hive_service.dart';
import 'services/todo_local_service.dart';
import 'services/auth_local_service.dart';
import 'utils/app_error_handler.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppErrorHandler.setup();

    TodoLocalService localService;
    var storageUnavailable = false;

    AuthLocalService? authLocalService;
    try {
      await HiveService.init();
      localService = await TodoLocalService.create();
      authLocalService = await AuthLocalService.create();
    } catch (error, stack) {
      AppErrorHandler.log(error, stack);
      localService = TodoLocalService.inMemory();
      storageUnavailable = true;
    }

    final repository = TodoRepository(localService: localService);
    final themeProvider = ThemeProvider();
    await themeProvider.load();

    final authRepo = AuthRepository(localService: authLocalService!);
    final authProvider = AuthProvider(repository: authRepo);
    await authProvider.checkAuthStatus();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProxyProvider<AuthProvider, TodoProvider>(
            create: (ctx) => TodoProvider(
              repository: repository,
              storageFallback: storageUnavailable,
              userId: authProvider.currentUser?.id,
            ),
            update: (ctx, auth, previous) {
              final newUserId = auth.currentUser?.id;
              if (previous != null && previous.userId == newUserId) {
                return previous;
              }
              return TodoProvider(
                repository: repository,
                storageFallback: storageUnavailable,
                userId: newUserId,
              )..loadTodos();
            },
          ),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const TodoApp(),
      ),
    );
  }, AppErrorHandler.log);
}
