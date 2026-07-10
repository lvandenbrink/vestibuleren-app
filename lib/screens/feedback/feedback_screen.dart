import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/adaptive_container.dart';
import '../../data/exercise_catalog.dart';
import '../../models/feedback_entry.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final String exerciseId;
  const FeedbackScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int? _rating;
  int? _painLevel;
  bool? _madeItWorse;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise =
        exerciseCatalog.where((e) => e.id == widget.exerciseId).firstOrNull;
    if (exercise == null) return const Scaffold(body: SizedBox.shrink());
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final grey = Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoe was de oefening?'),
        backgroundColor: colors.primaryContainer,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Annuleren',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AdaptiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                exercise.title,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Alle velden zijn optioneel.',
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 28),

              // Rating
              Text('Beoordeling oefening', style: text.titleMedium),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _rating != null ? colors.primary : grey,
                  inactiveTrackColor:
                      _rating != null
                          ? colors.primary.withAlpha(40)
                          : grey.withAlpha(60),
                  thumbColor: _rating != null ? colors.primary : grey,
                ),
                child: Slider(
                  value: (_rating ?? 1).toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChangeStart: (_) {
                    if (_rating == null) setState(() => _rating = 1);
                  },
                  onChanged: (v) => setState(() => _rating = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Slecht', style: text.labelSmall?.copyWith(color: grey)),
                  if (_rating != null)
                    Text(
                      '$_rating / 10',
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  Text(
                    'Uitstekend',
                    style: text.labelSmall?.copyWith(color: grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pain level
              Text('Pijnniveau', style: text.titleMedium),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _painLevel != null ? colors.error : grey,
                  inactiveTrackColor:
                      _painLevel != null
                          ? colors.error.withAlpha(40)
                          : grey.withAlpha(60),
                  thumbColor: _painLevel != null ? colors.error : grey,
                ),
                child: Slider(
                  value: (_painLevel ?? 0).toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChangeStart: (_) {
                    if (_painLevel == null) setState(() => _painLevel = 0);
                  },
                  onChanged: (v) => setState(() => _painLevel = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Geen pijn',
                    style: text.labelSmall?.copyWith(color: grey),
                  ),
                  if (_painLevel != null)
                    Text(
                      '$_painLevel / 10',
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.error,
                      ),
                    ),
                  Text(
                    'Veel pijn',
                    style: text.labelSmall?.copyWith(color: grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Effect
              Text('Effect van de oefening', style: text.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EffectCard(
                      label: 'Beter / Geen verschil',
                      icon: Icons.thumb_up_outlined,
                      selected: _madeItWorse == false,
                      activeColor: colors.primary,
                      onTap: () => setState(() => _madeItWorse = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EffectCard(
                      label: 'Slechter',
                      icon: Icons.thumb_down_outlined,
                      selected: _madeItWorse == true,
                      activeColor: colors.error,
                      onTap: () => setState(() => _madeItWorse = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              Text('Notitie', style: text.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Optionele opmerkingen...',
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveAndContinue,
                child: const Text('Opslaan & doorgaan'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _skipAndContinue,
                child: Text(
                  'Overslaan',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    final bpm =
        ref.read(settingsProvider).exerciseSettings[widget.exerciseId]?.bpm;
    await ref
        .read(feedbackProvider.notifier)
        .addEntry(
          FeedbackEntry(
            exerciseId: widget.exerciseId,
            completedAt: DateTime.now(),
            rating: _rating,
            painLevel: _painLevel,
            madeItWorse: _madeItWorse,
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
            bpm: bpm,
          ),
        );
    await _navigateNext();
  }

  Future<void> _skipAndContinue() async {
    final bpm =
        ref.read(settingsProvider).exerciseSettings[widget.exerciseId]?.bpm;
    await ref
        .read(feedbackProvider.notifier)
        .addEntry(
          FeedbackEntry(
            exerciseId: widget.exerciseId,
            completedAt: DateTime.now(),
            bpm: bpm,
          ),
        );
    await _navigateNext();
  }

  Future<void> _navigateNext() async {
    final sessionState = ref.read(sessionProvider);
    if (sessionState.isComplete) {
      await ref.read(settingsProvider.notifier).markSessionComplete();
      if (mounted) context.go('/home');
    } else {
      final next = sessionState.current;
      if (next != null && mounted) {
        context.pushReplacement('/exercise/${next.exercise.id}');
      } else if (mounted) {
        context.go('/home');
      }
    }
  }
}

class _EffectCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _EffectCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : Colors.grey.shade400;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withAlpha(25) : null,
          border: Border.all(
            color: selected ? activeColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
