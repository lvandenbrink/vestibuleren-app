import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/session_provider.dart';

class ExercisesTab extends ConsumerWidget {
  const ExercisesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final total = session.items.length;

    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, size: 64, color: colors.primary),
              const SizedBox(height: 16),
              Text('Geen oefeningen geselecteerd.',
                  style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/settings'),
                child: const Text('Oefeningen kiezen'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: session.items.length,
            itemBuilder: (context, i) {
              final item = session.items[i];
              final isNext = !item.completed &&
                  session.items.take(i).every((prev) => prev.completed);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: item.completed
                        ? colors.primary
                        : isNext
                            ? colors.primaryContainer
                            : colors.surfaceContainerHighest,
                    child: item.completed
                        ? Icon(Icons.check, color: colors.onPrimary)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isNext
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  title: Text(item.exercise.title, style: text.titleMedium),
                  subtitle: Text(
                    item.exercise.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/exercise/${item.exercise.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
