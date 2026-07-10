import 'package:flutter/material.dart';
import '../../core/adaptive_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Over'),
        backgroundColor: colors.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: AdaptiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon.png',
                  width: 100,
                  height: 100,
                  errorBuilder:
                      (_, _, _) => Icon(
                        Icons.self_improvement_rounded,
                        size: 100,
                        color: colors.primary,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Vestibuleren',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versie 0.1',
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Vestibuleren helpt patiënten om hun vestibulair '
                    'revalidatieprogramma thuis bij te houden.\n\n'
                    'Voer uw oefeningen uit met begeleiding van een metronoom, '
                    'stel sets, reps en rusttijden in, en registreer uw voortgang '
                    'en klachten na elke sessie.\n\n'
                    'De statistieken geven u en uw therapeut inzicht in uw '
                    'herstelverloop over tijd.',
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '© 2026 Vestibuleren',
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
