import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/todo_form/todo_form_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
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
          builder: (_) => const TodoFormScreen(),
        );
      case AppRoutes.editTodo:
        final todoId = settings.arguments as String?;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => TodoFormScreen(todoId: todoId),
        );
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
