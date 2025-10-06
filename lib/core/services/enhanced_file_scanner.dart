import 'dart:async';
import 'dart:io';

import '../../models/file_item.dart';
import 'storage_stats_service.dart';

/// Enhanced file scanner that uses MediaStore API on Android for better performance
class EnhancedFileScannerService {
  final StorageStatsService _storageStatsService = StorageStatsService();

  /// Discover all files using MediaStore on Android
  Stream<FileItem> discoverFiles() async* {
    if (Platform.isAndroid) {
      yield* _discoverFilesAndroid();
    } else {
      yield* _discoverFilesLegacy();
    }
  }

  /// Discover files using MediaStore API on Android
  Stream<FileItem> _discoverFilesAndroid() async* {
    try {
      // Get all media files from MediaStore
      final mediaFiles = await _storageStatsService.getMediaFiles(type: 'all');
      
      for (final fileData in mediaFiles) {
        try {
          yield FileItem(
            id: fileData['id'] as String,
            path: fileData['path'] as String,
            name: fileData['name'] as String,
            size: (fileData['size'] as num).toInt(),
            mimeType: fileData['mimeType'] as String?,
            lastModified: DateTime.fromMillisecondsSinceEpoch(
              (fileData['lastModified'] as num).toInt(),
            ),
            lastAccessed: null,
          );
        } catch (e) {
          // Skip files that can't be processed
          continue;
        }
      }

      // Also scan downloads directory for non-media files
      yield* _scanDownloads();
      
      // Scan for APK files
      yield* _scanApks();
    } catch (e) {
      // If MediaStore fails, fallback to legacy scanning
      yield* _discoverFilesLegacy();
    }
  }

  /// Scan downloads directory for non-media files
  Stream<FileItem> _scanDownloads() async* {
    try {
      final downloadsPath = await _storageStatsService.getDownloadsPath();
      final downloadsDir = Directory(downloadsPath);
      
      if (!downloadsDir.existsSync()) return;

      await for (final entity in downloadsDir.list(recursive: false)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            final name = entity.uri.pathSegments.isNotEmpty 
                ? entity.uri.pathSegments.last 
                : entity.path;
            
            // Skip media files already captured by MediaStore
            if (_isMediaFile(name)) continue;

            yield FileItem(
              id: entity.path,
              path: entity.path,
              name: name,
              size: stat.size,
              mimeType: _getMimeType(name),
              lastModified: stat.modified,
              lastAccessed: stat.accessed,
            );
          } catch (_) {
            // Skip files that can't be accessed
          }
        }
      }
    } catch (_) {
      // Ignore download scan errors
    }
  }

  /// Scan for APK files
  Stream<FileItem> _scanApks() async* {
    try {
      final externalPath = await _storageStatsService.getExternalStoragePath();
      final downloadPath = await _storageStatsService.getDownloadsPath();
      
      final searchDirs = [
        Directory(downloadPath),
        Directory('$externalPath/Download'),
      ];

      for (final dir in searchDirs) {
        if (!dir.existsSync()) continue;

        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
            try {
              final stat = await entity.stat();
              yield FileItem(
                id: entity.path,
                path: entity.path,
                name: entity.uri.pathSegments.last,
                size: stat.size,
                mimeType: 'application/vnd.android.package-archive',
                lastModified: stat.modified,
                lastAccessed: stat.accessed,
              );
            } catch (_) {
              // Skip inaccessible APK files
            }
          }
        }
      }
    } catch (_) {
      // Ignore APK scan errors
    }
  }

  /// Legacy file discovery using directory scanning
  Stream<FileItem> _discoverFilesLegacy() async* {
    final List<Directory> roots = _defaultRoots();
    
    for (final root in roots) {
      if (!root.existsSync()) continue;
      final queue = <Directory>[root];
      int yielded = 0;
      
      while (queue.isNotEmpty) {
        final dir = queue.removeLast();
        final pathLower = dir.path.toLowerCase();
        
        if (_shouldSkipDir(pathLower)) continue;

        try {
          await for (final entity in dir
              .list(recursive: false, followLinks: false)
              .handleError((_) {}, test: (e) => e is FileSystemException)) {
            
            if (entity is File) {
              try {
                final stat = await entity.stat();
                yield FileItem(
                  id: entity.path,
                  path: entity.path,
                  name: entity.uri.pathSegments.isNotEmpty 
                      ? entity.uri.pathSegments.last 
                      : entity.path,
                  size: stat.size,
                  mimeType: _getMimeType(entity.path),
                  lastModified: stat.modified,
                  lastAccessed: stat.accessed,
                );
                yielded++;
                
                // Throttle to keep UI responsive
                if (yielded % 200 == 0) {
                  await Future<void>.delayed(const Duration(milliseconds: 1));
                }
              } catch (_) {
                // Skip unreadable files
              }
            } else if (entity is Directory) {
              final subPath = entity.path.toLowerCase();
              if (!_shouldSkipDir(subPath)) {
                queue.add(entity);
              }
            }
          }
        } catch (_) {
          // Skip directories we cannot list
        }
      }
    }
  }

  /// Get default root directories to scan
  List<Directory> _defaultRoots() {
    final List<Directory> dirs = <Directory>[];
    final ext = Directory('/storage/emulated/0');
    if (ext.existsSync()) dirs.add(ext);
    return dirs;
  }

  /// Check if directory should be skipped
  bool _shouldSkipDir(String lowerPath) {
    // Skip system and restricted directories
    if (lowerPath.endsWith('/android')) return true;
    if (lowerPath.contains('/android/data')) return true;
    if (lowerPath.contains('/android/obb')) return true;
    if (lowerPath.contains('/.')) return true; // Hidden directories
    return false;
  }

  /// Check if file is a media file
  bool _isMediaFile(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.flac') ||
        lower.endsWith('.m4a');
  }

  /// Get MIME type from filename
  String? _getMimeType(String path) {
    final lower = path.toLowerCase();
    
    // Images
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    
    // Videos
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.avi')) return 'video/x-msvideo';
    if (lower.endsWith('.mkv')) return 'video/x-matroska';
    
    // Audio
    if (lower.endsWith('.mp3')) return 'audio/mpeg';
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.flac')) return 'audio/flac';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    
    // Documents
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) return 'application/msword';
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.txt')) return 'text/plain';
    
    // APK
    if (lower.endsWith('.apk')) return 'application/vnd.android.package-archive';
    
    // Archives
    if (lower.endsWith('.zip')) return 'application/zip';
    if (lower.endsWith('.rar')) return 'application/x-rar-compressed';
    
    return null;
  }
}

