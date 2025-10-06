import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../../models/file_item.dart';
import '../../../widgets/file_tile.dart';
import '../../review/ui/review_screen.dart';

class JunkListView extends StatefulWidget {
  const JunkListView({super.key, this.items = const []});
  final List<FileItem> items;
  @override
  State<JunkListView> createState() => _JunkListViewState();
}

class _JunkListViewState extends State<JunkListView> {
  final Set<String> _selected = <String>{};
  int get _bytes => widget.items.where((e) => _selected.contains(e.id)).fold<int>(0, (a, b) => a + b.size);

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
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
              // TODO: Implement refresh functionality
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No junk items yet'))
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
            Expanded(child: Text('${_selected.length} selected · ${formatBytes(_bytes)}')),
            FilledButton.icon(
              onPressed: _selected.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewAndConfirmView(count: _selected.length, bytesLabel: formatBytes(_bytes)),
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


