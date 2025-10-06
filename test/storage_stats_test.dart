import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/core/services/storage_stats_service.dart';

void main() {
  group('StorageStats', () {
    test('calculates used percentage correctly', () {
      final stats = StorageStats(
        totalBytes: 1000,
        usedBytes: 250,
        freeBytes: 750,
      );

      expect(stats.usedPercentage, 25.0);
    });

    test('handles zero total bytes', () {
      final stats = StorageStats(
        totalBytes: 0,
        usedBytes: 0,
        freeBytes: 0,
      );

      expect(stats.usedPercentage, 0.0);
    });

    test('creates from map correctly', () {
      final map = {
        'totalBytes': 2000,
        'usedBytes': 1500,
        'freeBytes': 500,
      };

      final stats = StorageStats.fromMap(map);

      expect(stats.totalBytes, 2000);
      expect(stats.usedBytes, 1500);
      expect(stats.freeBytes, 500);
      expect(stats.usedPercentage, 75.0);
    });
  });

  group('DeviceStorageInfo', () {
    test('creates from map with internal and external storage', () {
      final map = {
        'internal': {
          'totalBytes': 1000,
          'usedBytes': 500,
          'freeBytes': 500,
        },
        'external': {
          'totalBytes': 2000,
          'usedBytes': 1000,
          'freeBytes': 1000,
        },
      };

      final deviceInfo = DeviceStorageInfo.fromMap(map);

      expect(deviceInfo.internal.totalBytes, 1000);
      expect(deviceInfo.external.totalBytes, 2000);
    });
  });

  group('CategoryBreakdown', () {
    test('calculates total correctly', () {
      final breakdown = CategoryBreakdown(
        images: 100,
        videos: 200,
        audio: 50,
        documents: 25,
        apks: 10,
        downloads: 30,
        cache: 15,
        other: 20,
      );

      expect(breakdown.total, 450);
    });

    test('creates from map with all categories', () {
      final map = {
        'images': 100,
        'videos': 200,
        'audio': 50,
        'documents': 25,
        'apks': 10,
        'downloads': 30,
        'cache': 15,
        'other': 20,
      };

      final breakdown = CategoryBreakdown.fromMap(map);

      expect(breakdown.images, 100);
      expect(breakdown.videos, 200);
      expect(breakdown.total, 450);
    });

    test('handles missing categories with zero defaults', () {
      final map = {
        'images': 100,
        'videos': 200,
      };

      final breakdown = CategoryBreakdown.fromMap(map);

      expect(breakdown.images, 100);
      expect(breakdown.videos, 200);
      expect(breakdown.audio, 0);
      expect(breakdown.documents, 0);
    });

    test('converts to map correctly', () {
      final breakdown = CategoryBreakdown(
        images: 100,
        videos: 200,
        audio: 50,
        documents: 25,
        apks: 10,
        downloads: 30,
        cache: 15,
        other: 20,
      );

      final map = breakdown.toMap();

      expect(map['Images'], 100);
      expect(map['Videos'], 200);
      expect(map['Audio'], 50);
      expect(map.length, 8);
    });
  });
}

