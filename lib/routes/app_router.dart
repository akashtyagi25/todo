import 'package:flutter/material.dart';

import '../screens/add_todo/add_todo_screen.dart';
import '../screens/home/home_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.addTodo:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AddTodoScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
