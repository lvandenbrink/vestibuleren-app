import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'exercises_tab.dart';
import 'history_tab.dart';
import 'stats_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  static const _tabs = [ExercisesTab(), StatsTab(), HistoryTab()];

  static const _labels = ['Oefeningen', 'Statistieken', 'Geschiedenis'];
  static const _icons = [
    Icons.fitness_center_outlined,
    Icons.bar_chart_outlined,
    Icons.history,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vestibuleren'),
        backgroundColor: colors.primaryContainer,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') context.push('/settings');
              if (value == 'about') context.push('/about');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'settings',
                child: Text('Oefeningen'),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('Over'),
              ),
            ],
          ),
        ],
      ),
      body: _tabs[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: List.generate(
          3,
          (i) =>
              NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
        ),
      ),
    );
  }
}
