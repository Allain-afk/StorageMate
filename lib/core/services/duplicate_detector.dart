import 'dart:io';

import '../../models/duplicate_group.dart';
import '../../models/file_item.dart';
import '../utils/hashing.dart';

class DuplicateDetector {
  /// Groups identical files using a multi-stage approach:
  /// 1) Size bucketing
  /// 2) Quick hash (first N KB)
  /// 3) Full content hash
  Future<List<DuplicateGroup>> detect(List<FileItem> files) async {
    final sizeBuckets = <int, List<FileItem>>{};
    for (final f in files) {
      (sizeBuckets[f.size] ??= <FileItem>[]).add(f);
    }

    final List<DuplicateGroup> groups = <DuplicateGroup>[];
    for (final entry in sizeBuckets.entries) {
      if (entry.key == 0 || entry.value.length < 2) continue;
      final quickBuckets = <String, List<FileItem>>{};
      for (final item in entry.value) {
        try {
          final quick = await HashingUtils.quickHashPrefix(File(item.path));
          (quickBuckets[quick] ??= <FileItem>[]).add(item);
        } catch (_) {}
      }

      for (final q in quickBuckets.values) {
        if (q.length < 2) continue;
        final fullBuckets = <String, List<FileItem>>{};
        for (final item in q) {
          try {
            final full = await HashingUtils.sha256File(File(item.path));
            (fullBuckets[full] ??= <FileItem>[]).add(item);
          } catch (_) {}
        }
        for (final dupSet in fullBuckets.values) {
          if (dupSet.length < 2) continue;
          final representative = _pickRepresentative(dupSet);
          groups.add(DuplicateGroup(
            groupId: _stableGroupId(dupSet.map((e) => e.path)),
            items: List<FileItem>.unmodifiable(dupSet),
            representativeId: representative.id,
          ));
        }
      }
    }
    return groups;
  }

  FileItem _pickRepresentative(List<FileItem> items) {
    // Prefer most recent in Camera/DCIM folder when possible
    FileItem best = items.first;
    for (final it in items) {
      final inCamera = it.path.contains('/DCIM/') || it.path.contains('/Camera/');
      final bestInCamera = best.path.contains('/DCIM/') || best.path.contains('/Camera/');
      if (inCamera && !bestInCamera) {
        best = it;
      } else if (inCamera == bestInCamera && it.lastModified.isAfter(best.lastModified)) {
        best = it;
      }
    }
    return best;
  }

  String _stableGroupId(Iterable<String> paths) {
    final list = paths.toList()..sort();
    return list.join('|').hashCode.toString();
  }
}


