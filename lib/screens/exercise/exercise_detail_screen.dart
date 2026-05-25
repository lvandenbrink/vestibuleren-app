import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/exercise_catalog.dart';
import '../../models/exercise.dart';
import '../../providers/metronome_provider.dart';
import '../../providers/settings_provider.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with WidgetsBindingObserver {
  late Exercise _exercise;
  late int _bpm;
  late int _reps;
  late int _sets;
  late int _rest;
  bool _settingsExpanded = false;
  bool _exerciseNotFound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final match = exerciseCatalog.where((e) => e.id == widget.exerciseId).firstOrNull;
    if (match == null) {
      _exerciseNotFound = true;
      return;
    }
    _exercise = match;
    final ex = ref.read(settingsProvider).exerciseSettings[_exercise.id];
    _settingsExpanded = ex == null;
    _bpm = ex?.bpm ?? _exercise.defaultBpm;
    _reps = ex?.reps ?? 30;
    _sets = ex?.sets ?? 1;
    _rest = ex?.restSeconds ?? 30;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    ref.read(metronomeProvider.notifier).handleAppLifecycle(active);
  }

  int get _totalSeconds {
    final rest = _sets > 1 ? _rest * (_sets - 1) : 0;
    return _reps * _sets + rest;
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String _fmtShort(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final sec = s % 60;
    return sec == 0 ? '${m}m' : '${m}m ${sec}s';
  }

  String get _settingsSummary {
    final bpm = _bpm == 0 ? 'Geen metronoom' : '$_bpm BPM';
    final sets = _sets == 1 ? '1 set' : '$_sets sets';
    return '$bpm  ·  ${_fmtShort(_reps)}  ·  $sets  ·  Totaal: ${_fmtShort(_totalSeconds)}';
  }

  Future<void> _saveBpm(int v) =>
      ref.read(settingsProvider.notifier).updateExerciseBpm(_exercise.id, v);
  Future<void> _saveReps(int v) =>
      ref.read(settingsProvider.notifier).updateExerciseReps(_exercise.id, v);
  Future<void> _saveSets(int v) =>
      ref.read(settingsProvider.notifier).updateExerciseSets(_exercise.id, v);
  Future<void> _saveRest(int v) => ref
      .read(settingsProvider.notifier)
      .updateExerciseRestSeconds(_exercise.id, v);

  Future<void> _editSeconds(
      String label, int current, int min, int max, void Function(int) apply) async {
    final controller = TextEditingController(text: current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: '$min – $max seconden'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuleren')),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v >= min && v <= max) Navigator.pop(ctx, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null) apply(result);
  }

  @override
  Widget build(BuildContext context) {
    if (_exerciseNotFound) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Oefening niet gevonden.')),
      );
    }

    final metronome = ref.watch(metronomeProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    ref.listen<MetronomeState>(metronomeProvider, (prev, next) {
      if (prev != null && !prev.isFinished && next.isFinished) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pushReplacement('/feedback/${_exercise.id}');
        });
      }
    });

    final isIdle = metronome.isIdle;

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise.title),
        backgroundColor: colors.primaryContainer,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExerciseContent(contentPath: _exercise.contentPath),
            const SizedBox(height: 16),

            // Settings (foldable)
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: _settingsExpanded,
                onExpansionChanged: (v) =>
                    setState(() => _settingsExpanded = v),
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Row(
                  children: [
                    Text('Instellingen',
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (!isIdle) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 12,
                                color: colors.onSecondaryContainer),
                            const SizedBox(width: 4),
                            Text('Bezig',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSecondaryContainer,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: _settingsExpanded
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _settingsSummary,
                          style: text.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ),
                children: [
                  // Metronoom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Metronoom', style: text.bodyMedium),
                      Text(
                        _bpm == 0 ? 'Uit' : '$_bpm BPM',
                        style:
                            text.labelLarge?.copyWith(color: colors.primary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('10', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _bpm == 0 ? 10.0 : _bpm.toDouble(),
                          min: 10,
                          max: 250,
                          divisions: 48,
                          label: '$_bpm BPM',
                          onChanged: isIdle
                              ? (v) => setState(() => _bpm = v.round())
                              : null,
                          onChangeEnd:
                              isIdle ? (v) => _saveBpm(v.round()) : null,
                        ),
                      ),
                      const Text('250', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Switch(
                        value: _bpm > 0,
                        onChanged: isIdle
                            ? (on) {
                                setState(() => _bpm = on ? 60 : 0);
                                _saveBpm(on ? 60 : 0);
                              }
                            : null,
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Reps
                  _SettingRow(
                    label: 'Reps',
                    trailing: _StepperControl(
                      value: _fmtShort(_reps),
                      decrementTooltip: 'Minder',
                      incrementTooltip: 'Meer',
                      onDecrement: isIdle && _reps > 5
                          ? () {
                              setState(
                                  () => _reps = (_reps - 5).clamp(5, 300));
                              _saveReps(_reps);
                            }
                          : null,
                      onIncrement: isIdle && _reps < 300
                          ? () {
                              setState(
                                  () => _reps = (_reps + 5).clamp(5, 300));
                              _saveReps(_reps);
                            }
                          : null,
                      onEdit: isIdle
                          ? () => _editSeconds(
                                'Reps (5–300s)', _reps, 5, 300,
                                (v) {
                                  setState(() => _reps = v);
                                  _saveReps(v);
                                },
                              )
                          : null,
                    ),
                  ),

                  const Divider(height: 24),

                  // Sets
                  _SettingRow(
                    label: 'Sets',
                    trailing: _StepperControl(
                      value: '$_sets',
                      decrementTooltip: 'Minder sets',
                      incrementTooltip: 'Meer sets',
                      onDecrement: isIdle && _sets > 1
                          ? () {
                              setState(() => _sets--);
                              _saveSets(_sets);
                            }
                          : null,
                      onIncrement: isIdle && _sets < 20
                          ? () {
                              setState(() => _sets++);
                              _saveSets(_sets);
                            }
                          : null,
                    ),
                  ),

                  const Divider(height: 24),

                  // Rest between sets
                  _SettingRow(
                    label: 'Rust tussen sets',
                    trailing: _StepperControl(
                      value: _fmtShort(_rest),
                      decrementTooltip: 'Minder rust',
                      incrementTooltip: 'Meer rust',
                      onDecrement: isIdle && _sets > 1 && _rest > 0
                          ? () {
                              setState(
                                  () => _rest = (_rest - 5).clamp(0, 120));
                              _saveRest(_rest);
                            }
                          : null,
                      onIncrement: isIdle && _sets > 1 && _rest < 120
                          ? () {
                              setState(
                                  () => _rest = (_rest + 5).clamp(0, 120));
                              _saveRest(_rest);
                            }
                          : null,
                      onEdit: isIdle && _sets > 1
                          ? () => _editSeconds(
                                'Rust (0–120s)', _rest, 0, 120,
                                (v) {
                                  setState(() => _rest = v);
                                  _saveRest(v);
                                },
                              )
                          : null,
                    ),
                  ),

                  const Divider(height: 24),

                  // Total time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Totale tijd',
                          style: text.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        _fmtShort(_totalSeconds),
                        style: text.titleSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (!isIdle && _sets > 1) ...[
                    Text(
                      metronome.isResting
                          ? 'Rust'
                          : 'Set ${metronome.currentSet} / ${metronome.totalSets}',
                      style: text.labelLarge
                          ?.copyWith(color: colors.onPrimaryContainer),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    isIdle ? _fmt(_totalSeconds) : metronome.formattedTime,
                    style: text.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (!isIdle) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(
                        value: metronome.progress,
                        backgroundColor: colors.primary.withAlpha(50),
                        color: colors.primary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                  if (_bpm > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$_bpm BPM',
                      style: text.labelMedium
                          ?.copyWith(color: colors.onPrimaryContainer),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (!metronome.isFinished)
              ElevatedButton.icon(
                onPressed: () {
                  if (metronome.isRunning) {
                    ref.read(metronomeProvider.notifier).pause();
                  } else if (isIdle) {
                    unawaited(ref
                        .read(metronomeProvider.notifier)
                        .start(_reps, _sets, _rest, _bpm));
                  } else {
                    ref.read(metronomeProvider.notifier).resume(_bpm);
                  }
                },
                icon: Icon(metronome.isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(metronome.isRunning
                    ? 'Pauzeren'
                    : isIdle
                        ? 'Starten'
                        : 'Hervatten'),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  context.pushReplacement('/feedback/${_exercise.id}'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Klaar'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }
}

/// One settings row: label on the left, arbitrary trailing widget on the right.
/// Using Expanded on the label guarantees the trailing widget always anchors
/// to the same right edge regardless of label length.
class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        trailing,
      ],
    );
  }
}

/// Pill-shaped [−] value [+] stepper. The value area is a fixed 72 dp wide so
/// every stepper on screen has its buttons at exactly the same X positions.
class _StepperControl extends StatelessWidget {
  final String value;
  final String decrementTooltip;
  final String incrementTooltip;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final VoidCallback? onEdit;

  const _StepperControl({
    required this.value,
    required this.decrementTooltip,
    required this.incrementTooltip,
    this.onDecrement,
    this.onIncrement,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final enabled = onDecrement != null || onIncrement != null || onEdit != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: decrementTooltip,
            child: IconButton(
              icon: Icon(Icons.remove,
                  size: 18,
                  color: onDecrement != null
                      ? colors.onSurface
                      : colors.onSurface.withAlpha(60)),
              onPressed: onDecrement,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          Tooltip(
            message: onEdit != null ? 'Waarde aanpassen' : '',
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 72,
                height: 40,
                child: Center(
                  child: Text(
                    value,
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? colors.onSurface
                          : colors.onSurface.withAlpha(60),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Tooltip(
            message: incrementTooltip,
            child: IconButton(
              icon: Icon(Icons.add,
                  size: 18,
                  color: onIncrement != null
                      ? colors.onSurface
                      : colors.onSurface.withAlpha(60)),
              onPressed: onIncrement,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseContent extends StatelessWidget {
  final String contentPath;
  const _ExerciseContent({required this.contentPath});

  String _body(String raw) {
    if (!raw.startsWith('---')) return raw;
    final end = raw.indexOf('\n---', 3);
    return end == -1 ? raw : raw.substring(end + 4).trim();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(contentPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data: _body(snapshot.requireData),
              imageBuilder: (uri, _, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.asset(
                  'assets/exercises/${uri.path}',
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
