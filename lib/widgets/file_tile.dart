import 'package:flutter/material.dart';

import '../core/utils/format.dart';
import '../models/file_item.dart';

class FileTile extends StatelessWidget {
  const FileTile({super.key, required this.item, this.trailing, this.onTap, this.selected = false});
  final FileItem item;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(_iconFor(item))),
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${formatBytes(item.size)} · ${item.path}'),
      trailing: trailing,
      selected: selected,
    );
  }

  IconData _iconFor(FileItem f) {
    final p = f.path.toLowerCase();
    if (p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png')) return Icons.photo_outlined;
    if (p.endsWith('.mp4') || p.endsWith('.mov')) return Icons.movie_outlined;
    if (p.endsWith('.mp3') || p.endsWith('.wav')) return Icons.audiotrack_outlined;
    if (p.endsWith('.apk')) return Icons.android_outlined;
    return Icons.insert_drive_file_outlined;
  }
}


