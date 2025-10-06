import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/models/scan_result.dart';
import 'package:storagemate/models/duplicate_group.dart';
import 'package:storagemate/models/file_item.dart';

void main() {
  test('ScanResult aggregates counts', () {
    final result = ScanResult(
      discoveredCount: 10,
      scannedCount: 8,
      bytesTotal: 1000,
      bytesReclaimable: 200,
      duplicates: const <DuplicateGroup>[],
      junk: const <FileItem>[],
      rare: const <FileItem>[],
    );
    expect(result.discoveredCount, 10);
    expect(result.bytesReclaimable, 200);
  });
}


