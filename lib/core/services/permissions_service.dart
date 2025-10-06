import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  /// Ensure storage access permissions are granted
  /// Returns true if permissions are granted, false otherwise
  Future<bool> ensureStorageAccess() async {
    if (!Platform.isAndroid) return true;

    // Check Android version to determine which permissions to request
    final androidVersion = await _getAndroidVersion();
    
    // Android 11+ (API 30+): Request MANAGE_EXTERNAL_STORAGE for full access
    if (androidVersion >= 30) {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isGranted) {
        return true;
      }
      
      // If not granted, request it
      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        return true;
      }
      
      // If denied, fallback to basic media permissions for Android 13+
      if (androidVersion >= 33) {
        return await _requestMediaPermissions();
      }
    }
    
    // Android 13+ (API 33+): Use granular media permissions
    if (androidVersion >= 33) {
      return await _requestMediaPermissions();
    }
    
    // Android 10-12 (API 29-32): Use legacy storage permission
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return true;
    }
    
    final result = await Permission.storage.request();
    return result.isGranted;
  }

  /// Request media permissions for Android 13+
  Future<bool> _requestMediaPermissions() async {
    final statuses = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();
    
    // Return true if at least one permission is granted
    return statuses.values.any((s) => s.isGranted);
  }

  /// Check if MANAGE_EXTERNAL_STORAGE permission is granted
  Future<bool> hasManageStoragePermission() async {
    if (!Platform.isAndroid) return false;
    
    final androidVersion = await _getAndroidVersion();
    if (androidVersion < 30) return false;
    
    final status = await Permission.manageExternalStorage.status;
    return status.isGranted;
  }

  /// Open app settings for user to grant permissions manually
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get Android API version
  Future<int> _getAndroidVersion() async {
    // Try to get from platform-specific code if available
    // For now, assume latest version for best compatibility
    // In production, this should be obtained from a platform channel
    return 33; // Default to Android 13
  }
}



