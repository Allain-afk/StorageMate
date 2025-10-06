import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/section.dart';
import '../../../utils/back_handler.dart';
import '../../../widgets/stats_cards.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/utils/format.dart';
import '../../scan/controller/scan_controller.dart';
import '../../../models/scan_result.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  void _showFilesBreakdown(BuildContext context, ScanResult result) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Files Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildBreakdownCard(
                      context,
                      'Duplicates',
                      result.duplicates.length,
                      result.duplicates.fold<int>(0, (sum, group) {
                        return sum + group.items.where((item) => item.id != group.representativeId)
                            .fold<int>(0, (s, i) => s + i.size);
                      }),
                      Icons.copy_all_outlined,
                      Colors.orange,
                      () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(
                      context,
                      'Junk Files',
                      result.junk.length,
                      result.junk.fold<int>(0, (sum, file) => sum + file.size),
                      Icons.delete_sweep_outlined,
                      Colors.red,
                      () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(
                      context,
                      'Rarely Used',
                      result.rare.length,
                      result.rare.fold<int>(0, (sum, file) => sum + file.size),
                      Icons.access_time_outlined,
                      Colors.blue,
                      () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(
                      context,
                      'Total Files',
                      result.discoveredCount,
                      result.bytesTotal,
                      Icons.folder_outlined,
                      Colors.grey,
                      null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context,
    String title,
    int count,
    int bytes,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count files · ${formatBytes(bytes)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageStats = ref.watch(storageStatsNotifierProvider);
    final scanResult = ref.watch(scanControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StorageMate'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(storageStatsNotifierProvider.notifier).refresh();
              ref.read(categoryBreakdownNotifierProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
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
            child: storageStats.when(
              data: (deviceInfo) {
                final storage = deviceInfo.external; // Primary user storage
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  children: [
                    StatCard(
                      title: 'Used',
                      value: formatBytes(storage.usedBytes),
                      subtitle: 'of ${formatBytes(storage.totalBytes)}',
                      icon: Icons.storage,
                    ),
                    StatCard(
                      title: 'Free',
                      value: formatBytes(storage.freeBytes),
                      subtitle: '${storage.usedPercentage.toStringAsFixed(1)}% used',
                      icon: Icons.check_circle_outline,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/results'),
                      child: StatCard(
                        title: 'Reclaimable',
                        value: scanResult.when(
                          data: (result) => result != null ? formatBytes(result.bytesReclaimable) : '—',
                          loading: () => '—',
                          error: (_, __) => '—',
                        ),
                        subtitle: 'tap to view',
                        icon: Icons.cleaning_services_outlined,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        scanResult.whenData((result) {
                          if (result != null) {
                            _showFilesBreakdown(context, result);
                          }
                        });
                      },
                      child: StatCard(
                        title: 'Files',
                        value: scanResult.when(
                          data: (result) => result != null ? result.discoveredCount.toString() : '—',
                          loading: () => '—',
                          error: (_, __) => '—',
                        ),
                        subtitle: 'tap to view',
                        icon: Icons.insert_drive_file_outlined,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load storage data',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Section(
            title: 'Quick Actions',
            child: Column(
              children: [
                _ActionCard(
                  title: 'Clean Now',
                  subtitle: 'Remove junk files and duplicates',
                  icon: Icons.cleaning_services_outlined,
                  onTap: () => context.go('/scan'),
                  primary: true,
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'View Results',
                  subtitle: 'See scan results and recommendations',
                  icon: Icons.list_alt_outlined,
                  onTap: () => context.go('/results'),
                ),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary 
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primary 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
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


