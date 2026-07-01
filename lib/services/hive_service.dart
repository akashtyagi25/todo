import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/todo.dart';
import '../models/todo_adapter.dart';
import '../models/user.dart';
import '../models/user_adapter.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        Hive.init('todo_hive');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        Hive.init(directory.path);
      }

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TodoAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserAdapter());
      }

      _initialized = true;
    } catch (error) {
      throw StorageException(
        'Unable to initialize local storage. Please restart the app.',
      );
    }
  }

  static Future<Box<Todo>> openTodosBox() async {
    await init();

    if (Hive.isBoxOpen(AppConstants.todosBoxName)) {
      return Hive.box<Todo>(AppConstants.todosBoxName);
    }

    try {
      return await Hive.openBox<Todo>(AppConstants.todosBoxName);
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(AppConstants.todosBoxName);
        return await Hive.openBox<Todo>(AppConstants.todosBoxName);
      } catch (error) {
        throw StorageException();
      }
    }
  }

  static Future<Box<User>> openUsersBox() async {
    await init();
    if (Hive.isBoxOpen(AppConstants.usersBoxName)) {
      return Hive.box<User>(AppConstants.usersBoxName);
    }
    return await Hive.openBox<User>(AppConstants.usersBoxName);
  }

  static Future<Box<dynamic>> openAuthBox() async {
    await init();
    if (Hive.isBoxOpen(AppConstants.authBoxName)) {
      return Hive.box<dynamic>(AppConstants.authBoxName);
    }
    return await Hive.openBox<dynamic>(AppConstants.authBoxName);
  }
}
