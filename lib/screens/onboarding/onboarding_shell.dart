import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/exercise_catalog.dart';
import '../../providers/settings_provider.dart';

class OnboardingShell extends ConsumerStatefulWidget {
  const OnboardingShell({super.key});

  @override
  ConsumerState<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends ConsumerState<OnboardingShell> {
  final _controller = PageController();
  int _currentPage = 0;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding(
          selectedIds: _selectedIds.toList(),
        );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == i
                        ? colors.primary
                        : colors.primary.withAlpha(80),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _WelcomePage(onNext: _next),
                  _ExerciseSelectionPage(
                    selectedIds: _selectedIds,
                    onToggle: (id) => setState(() {
                      if (_selectedIds.contains(id)) {
                        _selectedIds.remove(id);
                      } else {
                        _selectedIds.add(id);
                      }
                    }),
                    onFinish: _finish,
                    onBack: _prev,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/icon.png',
              width: 100,
              height: 100,
              errorBuilder: (_, __, ___) => Icon(
                Icons.self_improvement_rounded,
                size: 100,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Welkom bij Vestibuleren',
              style:
                  text.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Deze app helpt u thuis uw vestibulair revalidatieprogramma '
            'bij te houden.\n\n'
            '• Volg uw dagelijkse oefeningen\n'
            '• Timer met metronoom begeleiding\n'
            '• Stel sets, reps en rusttijden in\n'
            '• Registreer uw voortgang en klachten',
            style: text.bodyLarge,
            textAlign: TextAlign.left,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Aan de slag'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSelectionPage extends StatelessWidget {
  final Set<String> selectedIds;
  final void Function(String id) onToggle;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const _ExerciseSelectionPage({
    required this.selectedIds,
    required this.onToggle,
    required this.onFinish,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kies uw oefeningen',
                  style: text.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                  'Selecteer de oefeningen die uw therapeut heeft aanbevolen.',
                  style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: exerciseCatalog.length,
            itemBuilder: (context, i) {
              final ex = exerciseCatalog[i];
              return CheckboxListTile(
                value: selectedIds.contains(ex.id),
                onChanged: (_) => onToggle(ex.id),
                title: Text(ex.title),
                subtitle: Text(ex.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selectedIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Selecteer minimaal één oefening om te beginnen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onBack,
                      child: const Text('Terug'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedIds.isNotEmpty ? onFinish : null,
                      child: const Text('Starten'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
