import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../../models/file_item.dart';
import '../../../widgets/file_tile.dart';
import '../../review/ui/review_screen.dart';
import '../../scan/controller/scan_controller.dart';

class JunkListViewRealData extends ConsumerStatefulWidget {
  const JunkListViewRealData({super.key});
  
  @override
  ConsumerState<JunkListViewRealData> createState() => _JunkListViewRealDataState();
}

class _JunkListViewRealDataState extends ConsumerState<JunkListViewRealData> {
  final Set<String> _selected = <String>{};
  
  int _calculateBytes(List<FileItem> items) {
    return items.where((e) => _selected.contains(e.id)).fold<int>(0, (a, b) => a + b.size);
  }

  @override
  Widget build(BuildContext context) {
    final scanResult = ref.watch(scanControllerProvider);
    
    return scanResult.when(
      data: (result) {
        final items = result?.junk ?? [];
        final bytes = _calculateBytes(items);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Junk'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/results'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(scanControllerProvider);
                },
              ),
            ],
          ),
          body: items.isEmpty
              ? const Center(child: Text('No junk items found'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    final checked = _selected.contains(it.id);
                    return FileTile(
                      item: it,
                      trailing: Checkbox(value: checked, onChanged: (_) => _toggle(it.id)),
                      onTap: () => _toggle(it.id),
                      selected: checked,
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(child: Text('${_selected.length} selected · ${formatBytes(bytes)}')),
                FilledButton.icon(
                  onPressed: _selected.isEmpty
                      ? null
                  : () {
                      final selectedFiles = items.where((item) => _selected.contains(item.id)).toList();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewAndConfirmView(
                            count: _selected.length,
                            bytesLabel: formatBytes(bytes),
                            filesToDelete: selectedFiles,
                          ),
                        ),
                      );
                    },
                  icon: const Icon(Icons.check),
                  label: const Text('Review'),
                ),
              ]),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Junk')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Junk')),
        body: Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }
}

