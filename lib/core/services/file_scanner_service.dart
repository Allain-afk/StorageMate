import 'dart:async';
import 'dart:io';

import '../../models/file_item.dart';

class FileScannerService {
  FileScannerService({List<Directory>? roots}) : roots = roots ?? _defaultRoots();

  final List<Directory> roots;

  static List<Directory> _defaultRoots() {
    final List<Directory> dirs = <Directory>[];
    final ext = Directory('/storage/emulated/0');
    if (ext.existsSync()) dirs.add(ext);
    final downloads = Directory('/storage/emulated/0/Download');
    if (downloads.existsSync()) dirs.add(downloads);
    return dirs;
  }

  Stream<FileItem> discoverFiles({bool followLinks = false}) async* {
    for (final root in roots) {
      if (!root.existsSync()) continue;
      await for (final entity in root.list(recursive: true, followLinks: followLinks)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            yield FileItem(
              id: entity.path,
              path: entity.path,
              name: entity.uri.pathSegments.isNotEmpty ? entity.uri.pathSegments.last : entity.path,
              size: stat.size,
              mimeType: null,
              lastModified: stat.modified,
              lastAccessed: stat.accessed,
            );
          } catch (_) {
            // ignore unreadable file
          }
        }
      }
    }
  }
}


