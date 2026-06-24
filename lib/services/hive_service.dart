import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../models/todo.dart';
import '../models/todo_adapter.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      Hive.init('todo_hive');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }

    _initialized = true;
  }

  static Future<Box<Todo>> openTodosBox() async {
    await init();

    if (Hive.isBoxOpen(AppConstants.todosBoxName)) {
      return Hive.box<Todo>(AppConstants.todosBoxName);
    }

    try {
      return await Hive.openBox<Todo>(AppConstants.todosBoxName);
    } catch (_) {
      await Hive.deleteBoxFromDisk(AppConstants.todosBoxName);
      return Hive.openBox<Todo>(AppConstants.todosBoxName);
    }
  }
}
