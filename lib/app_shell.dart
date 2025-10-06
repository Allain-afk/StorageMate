import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexForLocation(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/scan')) return 1;
    if (loc.startsWith('/results') || loc.startsWith('/duplicates') || loc.startsWith('/junk') || loc.startsWith('/recents')) return 2;
    return 0; // dashboard
  }

  void _onTap(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        context.go('/');
      case 1:
        context.go('/scan');
      case 2:
        context.go('/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexForLocation(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Results'),
        ],
      ),
    );
  }
}


