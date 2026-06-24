import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
