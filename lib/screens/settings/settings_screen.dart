import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/adaptive_container.dart';
import '../../data/exercise_catalog.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
        backgroundColor: colors.primaryContainer,
      ),
      body: AdaptiveContainer(
        child: ListView(
          children: [
            // ── Exercise selection ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Oefeningen', style: text.titleMedium),
            ),
            ...exerciseCatalog.map((ex) {
              final selected = settings.selectedExerciseIds.contains(ex.id);
              return CheckboxListTile(
                value: selected,
                onChanged: (_) {
                  final ids = settings.selectedExerciseIds.toList();
                  if (selected) {
                    ids.remove(ex.id);
                  } else {
                    ids.add(ex.id);
                  }
                  ref
                      .read(settingsProvider.notifier)
                      .updateExerciseSelection(ids);
                },
                title: Text(ex.title),
                subtitle: Text(
                  ex.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
