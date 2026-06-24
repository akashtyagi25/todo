import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todo/app.dart';
import 'package:todo/providers/todo_provider.dart';

void main() {
  testWidgets('Home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TodoProvider(),
        child: const TodoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No todos yet. Tap + to add one.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
