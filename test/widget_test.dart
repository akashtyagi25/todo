import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todo/app.dart';
import 'package:todo/constants/app_constants.dart';
import 'package:todo/providers/theme_provider.dart';
import 'package:todo/providers/todo_provider.dart';

void main() {
  testWidgets('Home screen shows empty state when no tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const TodoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.emptyTasksTitle), findsOneWidget);
    expect(find.text(AppConstants.emptyTasksSubtitle), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.text('Add Todo'), findsNothing);
  });
}
