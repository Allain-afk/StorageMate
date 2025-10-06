import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/duplicate_detector.dart';
import '../../../core/services/enhanced_file_scanner.dart';
import '../../../core/services/junk_classifier.dart';
import '../../../core/services/storage_stats_service.dart';
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
      // Use enhanced scanner for better performance and accuracy
      final scanner = EnhancedFileScannerService();
      final files = <FileItem>[];
      
      await for (final f in scanner.discoverFiles()) {
        files.add(f);
      }
      
      // Calculate total bytes from scanned files
      int bytesTotal = 0;
      for (final f in files) {
        bytesTotal += f.size;
      }
      
      // Detect duplicates
      final dupDetector = DuplicateDetector();
      final dups = await dupDetector.detect(files);
      
      // Classify junk files
      final junkClassifications = HeuristicJunkClassifier().classify(files);
      
      // Extract junk file IDs from recommendations
      final junkFileIds = junkClassifications.map((r) => r.id).toSet();
      final junkFiles = files.where((f) => junkFileIds.contains(f.id)).toList();
      final bytesReclaimable = junkClassifications.fold<int>(0, (a, r) => a + r.bytesReclaimable);
      
      // Identify rarely used files (not accessed in 90+ days)
      final now = DateTime.now();
      final rareFiles = files.where((f) {
        final lastAccess = f.lastAccessed ?? f.lastModified;
        final daysSinceAccess = now.difference(lastAccess).inDays;
        return daysSinceAccess > 90;
      }).toList();
      
      // Calculate duplicate bytes for reclaimable total
      int duplicateBytes = 0;
      for (final group in dups) {
        // All files except the one we keep are reclaimable
        duplicateBytes += group.items
            .where((item) => item.id != group.representativeId)
            .fold<int>(0, (sum, item) => sum + item.size);
      }
      
      final totalReclaimable = bytesReclaimable + duplicateBytes;
      
      state = AsyncData(ScanResult(
        discoveredCount: files.length,
        scannedCount: files.length,
        bytesTotal: bytesTotal,
        bytesReclaimable: totalReclaimable,
        duplicates: dups,
        junk: junkFiles,
        rare: rareFiles,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final scanControllerProvider = AsyncNotifierProvider<ScanController, ScanResult?>(() => ScanController());


