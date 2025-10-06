import 'dart:io';
import '../../models/file_item.dart';

/// Service for cleaning up files from device storage
class FileCleanupService {
  /// Delete a single file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file $filePath: $e');
      return false;
    }
  }

  /// Delete multiple files
  Future<CleanupResult> deleteFiles(List<String> filePaths) async {
    int successCount = 0;
    int failCount = 0;
    int bytesFreed = 0;
    List<String> failedFiles = [];

    for (final path in filePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          await file.delete();
          successCount++;
          bytesFreed += size;
        } else {
          failCount++;
          failedFiles.add(path);
        }
      } catch (e) {
        failCount++;
        failedFiles.add(path);
        print('Error deleting file $path: $e');
      }
    }

    return CleanupResult(
      successCount: successCount,
      failCount: failCount,
      bytesFreed: bytesFreed,
      failedFiles: failedFiles,
    );
  }

  /// Delete files from FileItem list
  Future<CleanupResult> deleteFileItems(List<FileItem> items) async {
    final paths = items.map((item) => item.path).toList();
    return await deleteFiles(paths);
  }

  /// Move file to trash (create .trash directory)
  Future<bool> moveToTrash(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      // Create trash directory
      final trashDir = Directory('/storage/emulated/0/.trash');
      if (!await trashDir.exists()) {
        await trashDir.create(recursive: true);
      }

      // Move file to trash
      final fileName = file.uri.pathSegments.last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final trashPath = '${trashDir.path}/${timestamp}_$fileName';
      
      await file.rename(trashPath);
      return true;
    } catch (e) {
      print('Error moving file to trash $filePath: $e');
      return false;
    }
  }

  /// Restore file from trash
  Future<bool> restoreFromTrash(String trashPath, String originalPath) async {
    try {
      final file = File(trashPath);
      if (!await file.exists()) return false;

      await file.rename(originalPath);
      return true;
    } catch (e) {
      print('Error restoring file $trashPath: $e');
      return false;
    }
  }

  /// Empty trash directory
  Future<int> emptyTrash() async {
    try {
      final trashDir = Directory('/storage/emulated/0/.trash');
      if (!await trashDir.exists()) return 0;

      int count = 0;
      await for (final entity in trashDir.list()) {
        if (entity is File) {
          await entity.delete();
          count++;
        }
      }
      return count;
    } catch (e) {
      print('Error emptying trash: $e');
      return 0;
    }
  }
}

/// Result of a cleanup operation
class CleanupResult {
  final int successCount;
  final int failCount;
  final int bytesFreed;
  final List<String> failedFiles;

  CleanupResult({
    required this.successCount,
    required this.failCount,
    required this.bytesFreed,
    required this.failedFiles,
  });

  bool get hasFailures => failCount > 0;
  bool get isComplete => failCount == 0;
  int get totalAttempted => successCount + failCount;
}

