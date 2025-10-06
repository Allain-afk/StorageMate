import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexForLocation(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc == '/') return 0; // dashboard
    if (loc.startsWith('/scan')) return 1;
    if (loc.startsWith('/results') || loc.startsWith('/duplicates') || loc.startsWith('/junk') || loc.startsWith('/recents')) return 2;
    return -1; // other screens (review, settings) - no bottom nav
  }

  void _onTap(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/scan');
        break;
      case 2:
        context.go('/results');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexForLocation(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }
        // No more pages in stack: prompt double-back to exit
        final messenger = ScaffoldMessenger.of(context);
        final now = DateTime.now();
        final prev = _lastBackPromptTime;
        if (prev == null || now.difference(prev) > const Duration(seconds: 2)) {
          _lastBackPromptTime = now;
          messenger.showSnackBar(const SnackBar(content: Text('Press back again to exit')));
        } else {
          // allow default behavior to exit app
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: idx >= 0 ? NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => _onTap(context, i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Scan'),
            NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Results'),
          ],
        ) : null,
      ),
    );
  }
}

DateTime? _lastBackPromptTime;


