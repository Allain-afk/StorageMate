import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/scan/ui/scan_progress_screen.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
import 'app_shell.dart';
import 'features/results/ui/results_screen.dart';
import 'features/duplicates/ui/duplicates_screen.dart';
import 'features/junk/ui/junk_screen.dart';
import 'features/recents/ui/recents_screen.dart';
import 'features/review/ui/review_screen.dart';
import 'features/settings/ui/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: StorageMateApp()));
}

final _router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (ctx, st, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', name: 'dashboard', builder: (ctx, st) => const DashboardView()),
        GoRoute(path: '/scan', name: 'scan', builder: (ctx, st) => const ScanProgressView()),
        GoRoute(path: '/results', name: 'results', builder: (ctx, st) => const ResultsView()),
        GoRoute(path: '/duplicates', name: 'duplicates', builder: (ctx, st) => const DuplicatesListView()),
        GoRoute(path: '/junk', name: 'junk', builder: (ctx, st) => const JunkListView()),
        GoRoute(path: '/recents', name: 'recents', builder: (ctx, st) => const RecentsListView()),
        GoRoute(path: '/review', name: 'review', builder: (ctx, st) => const ReviewAndConfirmView()),
        GoRoute(path: '/settings', name: 'settings', builder: (ctx, st) => const SettingsView()),
      ],
    ),
  ],
);

class StorageMateApp extends StatelessWidget {
  const StorageMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal);
    final theme = base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: Colors.teal.withValues(alpha: .15),
        labelTextStyle: WidgetStatePropertyAll(base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    return MaterialApp.router(
      title: 'StorageMate',
      theme: theme,
      routerConfig: _router,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StorageMate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Dashboard (placeholder)'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            ElevatedButton(onPressed: () => context.go('/scan'), child: const Text('Start Scan')),
            ElevatedButton(onPressed: () => context.go('/results'), child: const Text('Results')),
            ElevatedButton(onPressed: () => context.go('/settings'), child: const Text('Settings')),
          ]),
        ],
      ),
    );
  }
}

class ScanProgressScreen extends StatelessWidget {
  const ScanProgressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Scanning... (placeholder)')));
  }
}

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Results (placeholder)')));
  }
}

class DuplicatesScreen extends StatelessWidget {
  const DuplicatesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Duplicates (placeholder)')));
  }
}

class JunkScreen extends StatelessWidget {
  const JunkScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Junk (placeholder)')));
  }
}

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Rarely Used (placeholder)')));
  }
}

class ReviewAndConfirmScreen extends StatelessWidget {
  const ReviewAndConfirmScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Review & Confirm (placeholder)')));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings (placeholder)')));
  }
}
