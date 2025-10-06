import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/duplicate_group.dart';
import '../../../models/file_item.dart';
import '../../../widgets/file_tile.dart';
import '../../../core/utils/format.dart';
import '../../review/ui/review_screen.dart';
import '../../scan/controller/scan_controller.dart';

class DuplicatesListView extends ConsumerStatefulWidget {
  const DuplicatesListView({super.key});
  
  @override
  ConsumerState<DuplicatesListView> createState() => _DuplicatesListViewState();
}

class _DuplicatesListViewOld extends StatefulWidget {
  const _DuplicatesListViewOld({this.groups = const []});
  final List<DuplicateGroup> groups;
  @override
  State<DuplicatesListView> createState() => _DuplicatesListViewState();
}

class _DuplicatesListViewState extends ConsumerState<DuplicatesListView> {
  final Set<String> _selectedToRemove = <String>{};
  int get _count => _selectedToRemove.length;

  @override
  Widget build(BuildContext context) {
    final scanResult = ref.watch(scanControllerProvider);
    
    return scanResult.when(
      data: (result) {
        final groups = result?.duplicates ?? [];
        if (groups.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Duplicates'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/results'),
              ),
            ),
            body: const Center(child: Text('No duplicates found yet')),
          );
        }
        return _buildDuplicatesList(context, groups);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Duplicates'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/results'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Duplicates'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/results'),
          ),
        ),
        body: Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildDuplicatesList(BuildContext context, List<DuplicateGroup> groups) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/results'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement refresh functionality
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: groups.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final g = groups[index];
          final rep = g.items.firstWhere((e) => e.id == g.representativeId, orElse: () => g.items.first);
          return ListTile(
            title: Text('${g.items.length} files'),
            subtitle: Text(rep.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final sel = await Navigator.of(context).push<List<String>>(
                MaterialPageRoute(builder: (_) => GroupDetailView(group: g)),
              );
              if (sel != null && sel.isNotEmpty) {
                setState(() {
                  _selectedToRemove.addAll(sel);
                });
              }
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('$_count selected for removal')),
            FilledButton.icon(
              onPressed: _count == 0
                  ? null
                  : () {
                      // Get all selected files from groups
                      final selectedFiles = <FileItem>[];
                      int totalBytes = 0;
                      
                      for (final group in groups) {
                        final filesToRemove = group.items
                            .where((item) => _selectedToRemove.contains(item.id))
                            .toList();
                        selectedFiles.addAll(filesToRemove);
                        totalBytes += filesToRemove.fold<int>(0, (sum, item) => sum + item.size);
                      }
                      
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewAndConfirmView(
                            count: selectedFiles.length,
                            bytesLabel: formatBytes(totalBytes),
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
  }
}

class GroupDetailView extends StatefulWidget {
  const GroupDetailView({super.key, required this.group});
  final DuplicateGroup group;
  @override
  State<GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<GroupDetailView> {
  late String keepId;
  @override
  void initState() {
    super.initState();
    keepId = widget.group.representativeId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select copies to remove'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        itemCount: widget.group.items.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final FileItem item = widget.group.items[index];
          final isKeep = item.id == keepId;
          return FileTile(
            item: item,
            trailing: isKeep
                ? const Chip(label: Text('Keep'))
                : Checkbox(value: !isKeep, onChanged: (_) => setState(() => keepId = item.id)),
            onTap: () => setState(() => keepId = item.id),
            selected: isKeep,
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              final removeIds = widget.group.items.where((e) => e.id != keepId).map((e) => e.id).toList();
              Navigator.of(context).pop(removeIds);
            },
            icon: const Icon(Icons.check),
            label: const Text('Select to remove'),
          ),
        ),
      ),
    );
  }
}


