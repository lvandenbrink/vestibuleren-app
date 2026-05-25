import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Vestibuleren',
      theme: appTheme,
      routerConfig: router,
      builder: (context, child) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child!,
        ),
      ),
    );
  }
}
