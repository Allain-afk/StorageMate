import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/duplicate_detector.dart';
import '../../../core/services/file_scanner_service.dart';
import '../../../core/services/junk_classifier.dart';
import '../../../models/scan_result.dart';
import '../../../models/file_item.dart';

class ScanController extends AsyncNotifier<ScanResult?> {
  @override
  FutureOr<ScanResult?> build() async {
    return null;
  }

  Future<void> runScan() async {
    state = const AsyncLoading();
    try {
      final scanner = FileScannerService();
      final files = <FileItem>[];
      await for (final f in scanner.discoverFiles()) {
        files.add(f);
      }
      int bytesTotal = 0;
      for (final f in files) {
        bytesTotal += f.size;
      }
      final dupDetector = DuplicateDetector();
      final dups = await dupDetector.detect(files);
      final junk = HeuristicJunkClassifier().classify(files);
      final bytesReclaimable = junk.fold<int>(0, (a, r) => a + r.bytesReclaimable);
      state = AsyncData(ScanResult(
        discoveredCount: files.length,
        scannedCount: files.length,
        bytesTotal: bytesTotal,
        bytesReclaimable: bytesReclaimable,
        duplicates: dups,
        junk: const <FileItem>[],
        rare: const <FileItem>[],
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final scanControllerProvider = AsyncNotifierProvider<ScanController, ScanResult?>(() => ScanController());


