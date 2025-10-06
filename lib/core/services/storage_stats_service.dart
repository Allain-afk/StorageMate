import 'dart:io';
import 'package:flutter/services.dart';

/// Model for storage statistics
class StorageStats {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;

  StorageStats({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
  });

  double get usedPercentage => totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;

  factory StorageStats.fromMap(Map<String, dynamic> map) {
    return StorageStats(
      totalBytes: (map['totalBytes'] as num).toInt(),
      usedBytes: (map['usedBytes'] as num).toInt(),
      freeBytes: (map['freeBytes'] as num).toInt(),
    );
  }
}

/// Model for device storage information (internal + external)
class DeviceStorageInfo {
  final StorageStats internal;
  final StorageStats external;

  DeviceStorageInfo({
    required this.internal,
    required this.external,
  });

  factory DeviceStorageInfo.fromMap(Map<String, dynamic> map) {
    return DeviceStorageInfo(
      internal: StorageStats.fromMap(map['internal'] as Map<String, dynamic>),
      external: StorageStats.fromMap(map['external'] as Map<String, dynamic>),
    );
  }
}

/// Model for category breakdown
class CategoryBreakdown {
  final int images;
  final int videos;
  final int audio;
  final int documents;
  final int apks;
  final int downloads;
  final int cache;
  final int other;

  CategoryBreakdown({
    required this.images,
    required this.videos,
    required this.audio,
    required this.documents,
    required this.apks,
    required this.downloads,
    required this.cache,
    required this.other,
  });

  int get total => images + videos + audio + documents + apks + downloads + cache + other;

  factory CategoryBreakdown.fromMap(Map<String, dynamic> map) {
    return CategoryBreakdown(
      images: (map['images'] as num?)?.toInt() ?? 0,
      videos: (map['videos'] as num?)?.toInt() ?? 0,
      audio: (map['audio'] as num?)?.toInt() ?? 0,
      documents: (map['documents'] as num?)?.toInt() ?? 0,
      apks: (map['apks'] as num?)?.toInt() ?? 0,
      downloads: (map['downloads'] as num?)?.toInt() ?? 0,
      cache: (map['cache'] as num?)?.toInt() ?? 0,
      other: (map['other'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, int> toMap() {
    return {
      'Images': images,
      'Videos': videos,
      'Audio': audio,
      'Documents': documents,
      'APKs': apks,
      'Downloads': downloads,
      'Cache': cache,
      'Other': other,
    };
  }
}

/// Service for accessing device storage statistics via platform channel
class StorageStatsService {
  static const _channel = MethodChannel('app.storagemate/storage');

  /// Get device storage statistics
  Future<DeviceStorageInfo> getStorageStats() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Storage stats only available on Android');
    }

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getStorageStats');
      if (result == null) {
        throw Exception('Failed to get storage stats');
      }
      
      // Deep convert nested maps
      final Map<String, dynamic> convertedMap = {
        'internal': Map<String, dynamic>.from(result['internal'] as Map),
        'external': Map<String, dynamic>.from(result['external'] as Map),
      };
      
      return DeviceStorageInfo.fromMap(convertedMap);
    } on PlatformException catch (e) {
      throw Exception('Failed to get storage stats: ${e.message}');
    }
  }

  /// Get media files from MediaStore
  /// [type] can be: "images", "videos", "audio", or "all"
  Future<List<Map<String, dynamic>>> getMediaFiles({String type = 'all'}) async {
    if (!Platform.isAndroid) {
      return [];
    }

    try {
      final result = await _channel.invokeMethod<List<Object?>>('getMediaFiles', {'type': type});
      if (result == null) {
        return [];
      }
      
      // Convert each map in the list
      return result.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get media files: ${e.message}');
    }
  }

  /// Get category breakdown of storage usage
  Future<CategoryBreakdown> getCategoryBreakdown() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Category breakdown only available on Android');
    }

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getCategoryBreakdown');
      if (result == null) {
        throw Exception('Failed to get category breakdown');
      }
      
      // Convert to proper map type
      final Map<String, dynamic> convertedMap = {};
      result.forEach((key, value) {
        if (key is String) {
          convertedMap[key] = value;
        }
      });
      
      return CategoryBreakdown.fromMap(convertedMap);
    } on PlatformException catch (e) {
      throw Exception('Failed to get category breakdown: ${e.message}');
    }
  }

  /// Get external storage path
  Future<String> getExternalStoragePath() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('External storage path only available on Android');
    }

    try {
      final result = await _channel.invokeMethod<String>('getExternalStoragePath');
      return result ?? '/storage/emulated/0';
    } on PlatformException catch (e) {
      throw Exception('Failed to get external storage path: ${e.message}');
    }
  }

  /// Get downloads path
  Future<String> getDownloadsPath() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Downloads path only available on Android');
    }

    try {
      final result = await _channel.invokeMethod<String>('getDownloadsPath');
      return result ?? '/storage/emulated/0/Download';
    } on PlatformException catch (e) {
      throw Exception('Failed to get downloads path: ${e.message}');
    }
  }
}

