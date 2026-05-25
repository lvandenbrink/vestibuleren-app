import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../screens/onboarding/onboarding_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/exercise/exercise_detail_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';

Widget _narrow(Widget child) => Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 480),
    child: child,
  ),
);

final routerProvider = Provider<GoRouter>((ref) {
  final initiallyOnboarded = ref.read(settingsProvider).onboardingComplete;

  return GoRouter(
    initialLocation: initiallyOnboarded ? '/home' : '/onboarding',
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboardingComplete;
      final onOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboarded && !onOnboarding) return '/onboarding';
      if (onboarded && onOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => _narrow(const OnboardingShell()),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => _narrow(const HomeScreen()),
      ),
      GoRoute(
        path: '/exercise/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _narrow(ExerciseDetailScreen(exerciseId: id));
        },
      ),
      GoRoute(
        path: '/feedback/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _narrow(FeedbackScreen(exerciseId: id));
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => _narrow(const SettingsScreen()),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => _narrow(const AboutScreen()),
      ),
    ],
  );
});
