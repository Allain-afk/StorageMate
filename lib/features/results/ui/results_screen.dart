import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResultsView extends ConsumerStatefulWidget {
  const ResultsView({super.key});
  @override
  ConsumerState<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends ConsumerState<ResultsView> with TickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement refresh functionality
            },
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.copy_all_outlined), text: 'Duplicates'),
            Tab(icon: Icon(Icons.delete_sweep_outlined), text: 'Junk'),
            Tab(icon: Icon(Icons.access_time_outlined), text: 'Rarely used'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CategoryList(
            title: 'Duplicates',
            icon: Icons.copy_all_outlined,
            onTap: () => context.go('/duplicates'),
            label: 'No duplicate groups yet',
          ),
          _CategoryList(
            title: 'Junk',
            icon: Icons.delete_sweep_outlined,
            onTap: () => context.go('/junk'),
            label: 'No junk items yet',
          ),
          _CategoryList(
            title: 'Rarely used',
            icon: Icons.access_time_outlined,
            onTap: () => context.go('/recents'),
            label: 'No rarely used items yet',
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.label,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text('View $title'),
          ),
        ],
      ),
    );
  }
}


