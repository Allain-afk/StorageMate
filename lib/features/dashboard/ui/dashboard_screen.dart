import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/section.dart';
import '../../../widgets/stats_cards.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StorageMate'),
        actions: [
          IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings_outlined))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/scan'),
        label: const Text('Smart Clean'),
        icon: const Icon(Icons.auto_mode_outlined),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Section(
            title: 'Overview',
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              children: const [
                StatCard(title: 'Used', value: '—', subtitle: 'of total', icon: Icons.storage),
                StatCard(title: 'Free', value: '—', subtitle: '', icon: Icons.check_circle_outline),
                StatCard(title: 'Reclaimable', value: '—', subtitle: 'estimated', icon: Icons.cleaning_services_outlined),
                StatCard(title: 'Files', value: '—', subtitle: 'scanned', icon: Icons.insert_drive_file_outlined),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Section(
            title: 'Categories',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ChipButton(label: 'Duplicates', icon: Icons.copy_all_outlined, onTap: () => context.go('/duplicates')),
                _ChipButton(label: 'Junk', icon: Icons.delete_sweep_outlined, onTap: () => context.go('/junk')),
                _ChipButton(label: 'Rarely used', icon: Icons.access_time_outlined, onTap: () => context.go('/recents')),
                _ChipButton(label: 'Results', icon: Icons.list_alt_outlined, onTap: () => context.go('/results')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon),
      label: Text(label),
      onPressed: onTap,
    );
  }
}


