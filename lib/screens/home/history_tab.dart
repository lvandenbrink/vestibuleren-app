import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/exercise_catalog.dart';
import '../../providers/feedback_provider.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(feedbackProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: colors.outlineVariant),
            const SizedBox(height: 16),
            Text('Nog geen sessies voltooid.',
                style: text.titleMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
          ],
        ),
      );
    }

    final sorted = [...entries]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final entry = sorted[i];
        final exercise = exerciseCatalog
            .where((e) => e.id == entry.exerciseId)
            .firstOrNull;
        final title = exercise?.title ?? entry.exerciseId;
        final dateStr =
            DateFormat('dd MMM yyyy – HH:mm', 'nl').format(entry.completedAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Text(dateStr,
                        style: text.labelSmall
                            ?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (entry.rating != null)
                      _Chip(
                          icon: Icons.star_outline,
                          label: '${entry.rating}/10',
                          color: colors.primary),
                    if (entry.painLevel != null)
                      _Chip(
                          icon: Icons.healing_outlined,
                          label: 'Pijn ${entry.painLevel}/10',
                          color: colors.error),
                    if (entry.madeItWorse != null)
                      _Chip(
                          icon: entry.madeItWorse!
                              ? Icons.thumb_down_outlined
                              : Icons.thumb_up_outlined,
                          label: entry.madeItWorse! ? 'Slechter' : 'Beter',
                          color: entry.madeItWorse!
                              ? colors.error
                              : colors.primary),
                    if (entry.bpm != null && entry.bpm! > 0)
                      _Chip(
                          icon: Icons.music_note_outlined,
                          label: '${entry.bpm} BPM',
                          color: colors.secondary),
                  ],
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(entry.notes!,
                      style: text.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
