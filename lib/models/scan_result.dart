import 'duplicate_group.dart';
import 'file_item.dart';

class ScanResult {
  final int discoveredCount;
  final int scannedCount;
  final int bytesTotal;
  final int bytesReclaimable;
  final List<DuplicateGroup> duplicates;
  final List<FileItem> junk;
  final List<FileItem> rare;

  const ScanResult({
    required this.discoveredCount,
    required this.scannedCount,
    required this.bytesTotal,
    required this.bytesReclaimable,
    required this.duplicates,
    required this.junk,
    required this.rare,
  });
}


