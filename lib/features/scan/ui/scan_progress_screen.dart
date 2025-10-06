import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/scan_controller.dart';
import '../../../core/services/permissions_service.dart';

class ScanProgressView extends ConsumerWidget {
  const ScanProgressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Scanning')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: scan.when(
          data: (r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Scan complete', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (r != null) ...[
                _RowTile(label: 'Files', value: r.discoveredCount.toString()),
                _RowTile(label: 'Reclaimable', value: '${r.bytesReclaimable} B'),
              ] else const Text('No results'),
            ],
          ),
          error: (e, _) => SingleChildScrollView(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final allowed = await PermissionsService().ensureStorageAccess();
          if (allowed) {
            // ignore: use_build_context_synchronously
            ref.read(scanControllerProvider.notifier).runScan();
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied')));
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}


