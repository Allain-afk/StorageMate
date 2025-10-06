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
      body: Center(
        child: scan.when(
          data: (r) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Scan complete'),
              if (r != null) ...[
                Text('Files: ${r.discoveredCount}'),
                Text('Reclaimable: ${r.bytesReclaimable} bytes'),
              ],
            ],
          ),
          error: (e, _) => Text('Error: $e'),
          loading: () => const CircularProgressIndicator(),
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


