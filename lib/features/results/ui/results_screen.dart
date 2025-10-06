import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        children: const [
          _PlaceholderList(label: 'No duplicate groups yet'),
          _PlaceholderList(label: 'No junk items yet'),
          _PlaceholderList(label: 'No rarely used items yet'),
        ],
      ),
    );
  }
}

class _PlaceholderList extends StatelessWidget {
  const _PlaceholderList({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label),
    );
  }
}


