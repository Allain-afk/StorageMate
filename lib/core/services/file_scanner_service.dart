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
      final queue = <Directory>[root];
      int yielded = 0;
      while (queue.isNotEmpty) {
        final dir = queue.removeLast();
        final pathLower = dir.path.toLowerCase();
        if (_shouldSkipDir(pathLower)) {
          continue;
        }
        try {
          await for (final entity in dir
              .list(recursive: false, followLinks: followLinks)
              .handleError((_) {}, test: (e) => e is FileSystemException)) {
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
                yielded++;
                if (yielded % 200 == 0) {
                  // Throttle to keep UI responsive
                  await Future<void>.delayed(const Duration(milliseconds: 1));
                }
              } catch (_) {
                // ignore unreadable file
              }
            } else if (entity is Directory) {
              final subPath = entity.path.toLowerCase();
              if (_shouldSkipDir(subPath)) continue;
              queue.add(entity);
            }
          }
        } catch (_) {
          // ignore directories we cannot list (e.g., Android/data)
        }
      }
    }
  }

  bool _shouldSkipDir(String lowerPath) {
    // Skip restricted/scoped storage sensitive directories
    if (lowerPath.endsWith('/android')) return true;
    if (lowerPath.contains('/android/data')) return true;
    if (lowerPath.contains('/android/obb')) return true;
    return false;
  }
}


