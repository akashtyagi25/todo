import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../models/todo.dart';
import '../models/todo_adapter.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }

    _initialized = true;
  }

  static Future<Box<Todo>> openTodosBox() async {
    await init();
    return Hive.openBox<Todo>(AppConstants.todosBoxName);
  }
}
