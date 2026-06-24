import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../utils/todo_sort.dart';

class TodoSortButton extends StatelessWidget {
  const TodoSortButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<TodoSortOption>(
          tooltip: 'Sort todos',
          icon: const Icon(Icons.sort),
          initialValue: provider.activeSort,
          onSelected: provider.setSort,
          itemBuilder: (context) {
            return TodoSortOption.values.map((option) {
              return PopupMenuItem<TodoSortOption>(
                value: option,
                child: Row(
                  children: [
                    if (provider.activeSort == option)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}
