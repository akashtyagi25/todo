import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../utils/todo_filter.dart';

class TodoFilterBar extends StatelessWidget {
  const TodoFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: TodoFilterOption.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = TodoFilterOption.values[index];
              final isSelected = provider.activeFilter == filter;

              return FilterChip(
                label: Text(filter.label),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) => provider.setFilter(filter),
              );
            },
          ),
        );
      },
    );
  }
}
