import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: StorageMateApp()));
}

final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', name: 'dashboard', builder: (ctx, st) => const DashboardScreen()),
    GoRoute(path: '/scan', name: 'scan', builder: (ctx, st) => const ScanProgressScreen()),
    GoRoute(path: '/results', name: 'results', builder: (ctx, st) => const ResultsScreen()),
    GoRoute(path: '/duplicates', name: 'duplicates', builder: (ctx, st) => const DuplicatesScreen()),
    GoRoute(path: '/junk', name: 'junk', builder: (ctx, st) => const JunkScreen()),
    GoRoute(path: '/recents', name: 'recents', builder: (ctx, st) => const RecentsScreen()),
    GoRoute(path: '/review', name: 'review', builder: (ctx, st) => const ReviewAndConfirmScreen()),
    GoRoute(path: '/settings', name: 'settings', builder: (ctx, st) => const SettingsScreen()),
  ],
);

class StorageMateApp extends StatelessWidget {
  const StorageMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StorageMate',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
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
