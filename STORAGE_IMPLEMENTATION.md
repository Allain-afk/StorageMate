# Real Storage Implementation - StorageMate

## Overview

This document describes the implementation of real device storage data access in the StorageMate app, replacing all mock/placeholder data with actual device storage information.

## Architecture

### Platform Channel Implementation

#### Android Native Code (`StorageChannel.kt`)

- **Location**: `android/app/src/main/kotlin/app/storagemate/storagemate/StorageChannel.kt`
- **Purpose**: Provides access to Android storage APIs via platform channel
- **Key Features**:
  - Uses `StatFs` for storage statistics (total, used, free space)
  - Uses `MediaStore` API for media file access (images, videos, audio)
  - Calculates category breakdowns (images, videos, audio, documents, APKs, downloads, cache)
  - Returns both internal and external storage statistics

#### Methods Exposed:

1. `getStorageStats()` - Returns internal and external storage statistics
2. `getMediaFiles(type)` - Returns media files from MediaStore
3. `getCategoryBreakdown()` - Returns storage usage by category
4. `getExternalStoragePath()` - Returns external storage path
5. `getDownloadsPath()` - Returns downloads directory path

### Dart Services

#### 1. StorageStatsService (`lib/core/services/storage_stats_service.dart`)

- **Purpose**: Dart interface to the platform channel
- **Models**:
  - `StorageStats`: Total, used, free bytes for a storage volume
  - `DeviceStorageInfo`: Internal + external storage stats
  - `CategoryBreakdown`: Storage usage by file category
- **Methods**: Mirror the platform channel methods

#### 2. EnhancedFileScannerService (`lib/core/services/enhanced_file_scanner.dart`)

- **Purpose**: Improved file scanner using MediaStore on Android
- **Features**:
  - Uses MediaStore API for media files (faster and more reliable)
  - Scans downloads directory for non-media files
  - Finds APK files across storage
  - Falls back to legacy directory scanning if MediaStore fails
  - Automatically determines MIME types

#### 3. Updated PermissionsService (`lib/core/services/permissions_service.dart`)

- **Purpose**: Handle storage permissions for different Android versions
- **Logic**:
  - Android 11+ (API 30+): Requests `MANAGE_EXTERNAL_STORAGE` for full access
  - Android 13+ (API 33+): Falls back to granular media permissions if full access denied
  - Android 10-12: Uses legacy `READ_EXTERNAL_STORAGE`
  - Provides method to open app settings for manual permission grant

### State Management (Riverpod Providers)

#### File: `lib/core/providers/storage_provider.dart`

1. **storageStatsServiceProvider**: Provides `StorageStatsService` instance
2. **deviceStorageInfoProvider**: Future provider for device storage info
3. **categoryBreakdownProvider**: Future provider for category breakdown
4. **primaryStorageStatsProvider**: Future provider for primary storage stats
5. **storageStatsNotifierProvider**: StateNotifier with refresh capability
6. **categoryBreakdownNotifierProvider**: StateNotifier with refresh capability

### UI Updates

#### Dashboard (`lib/features/dashboard/ui/dashboard_screen.dart`)

- **Changed**: `StatelessWidget` → `ConsumerWidget`
- **Real Data Displayed**:
  - Used/Free storage (from `StorageStats`)
  - Reclaimable space (from scan results)
  - File count (from scan results)
  - Storage usage percentage
- **Features**:
  - Refresh button to reload storage stats
  - Loading states with progress indicator
  - Error handling with user-friendly messages

#### Duplicates Screen (`lib/features/duplicates/ui/duplicates_screen.dart`)

- **Changed**: `StatefulWidget` → `ConsumerStatefulWidget`
- **Real Data**: Displays actual duplicate files from scan results
- **States**: Loading, error, and data states properly handled

#### Scan Controller (`lib/features/scan/controller/scan_controller.dart`)

- **Updated**: Now uses `EnhancedFileScannerService`
- **Improvements**:
  - Better file discovery using MediaStore
  - Accurate duplicate detection
  - Identifies rarely-used files (90+ days)
  - Calculates total reclaimable space (duplicates + junk)

## Permissions Configuration

### AndroidManifest.xml

```xml
<!-- Android 13+ granular media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />

<!-- Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />

<!-- Android 11+ full storage access -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

## Data Flow

1. **App Launch**:

   - `StorageStatsNotifier` automatically loads storage stats
   - Dashboard displays real storage information

2. **User Initiates Scan**:

   - Permissions service ensures storage access
   - `EnhancedFileScannerService` discovers files via MediaStore
   - Files are classified (duplicates, junk, rarely-used)
   - Scan results stored in state

3. **Viewing Categories**:

   - Screens watch `scanControllerProvider`
   - Display actual file lists from scan results
   - Show real file counts and sizes

4. **Refresh**:
   - User taps refresh button
   - Notifiers reload from platform channel
   - UI updates automatically via Riverpod

## Performance Optimizations

1. **MediaStore Usage**: Faster than directory scanning, respects scoped storage
2. **Async Streaming**: Files discovered and yielded incrementally
3. **Throttling**: Every 200 files, brief delay to keep UI responsive
4. **Caching**: Storage stats cached until explicit refresh

## Error Handling

1. **Permission Denied**:

   - Shows user-friendly error message
   - Provides button to open settings
   - Falls back to partial data if available

2. **Platform Errors**:

   - All platform channel calls wrapped in try-catch
   - Errors propagated to UI with meaningful messages
   - Fallback to legacy methods where applicable

3. **File Access Errors**:
   - Individual file errors silently skipped
   - Scan continues with accessible files

## Testing Considerations

### Unit Tests (To Be Implemented)

- Test `StorageStats` calculations (percentage, etc.)
- Test category breakdown aggregation
- Mock platform channel responses
- Test permission logic for different Android versions

### Integration Tests (To Be Implemented)

- Test full scan flow
- Verify storage stats display on dashboard
- Test navigation to category screens with real data
- Test refresh functionality

### Widget Tests (To Be Implemented)

- Test loading states
- Test error states
- Test data display

## Known Limitations

1. **Android Version Detection**: Currently assumes Android 13. Should use platform channel to get actual SDK version.

2. **MediaStore Limitations**:

   - Only includes media files and some documents
   - Non-media files in arbitrary directories may be missed
   - Falls back to directory scanning for complete coverage

3. **Scoped Storage**:

   - Android 10+ restricts broad file access
   - MANAGE_EXTERNAL_STORAGE required for comprehensive scanning
   - User must manually grant permission via settings on some devices

4. **Performance**:
   - Large storage (100GB+) may take time to scan
   - Consider implementing background scanning with workmanager

## Future Enhancements

1. **Background Scanning**: Use WorkManager for periodic scans
2. **Incremental Scanning**: Only scan changed files
3. **SD Card Support**: Add SD card detection and scanning
4. **Storage Location Selection**: Let user choose internal/external/SD card
5. **Real-time Updates**: Listen to file system changes
6. **Category Customization**: Let users define custom categories
7. **Cloud Storage**: Include cloud storage in analysis

## Migration Notes

### From Mock to Real Data

**Before**: Dashboard showed hardcoded "—" values
**After**: Dashboard shows real device storage statistics

**Before**: Empty category screens
**After**: Category screens populated with actual scan results

**Before**: No storage breakdown
**After**: Detailed category breakdown (images, videos, audio, etc.)

### API Changes

- `DuplicatesListView`: No longer accepts `groups` parameter (uses scan results)
- `DashboardView`: Now a `ConsumerWidget` instead of `StatelessWidget`
- New providers added for storage statistics
- New service: `EnhancedFileScannerService`

## Deployment Checklist

- [x] Platform channel implemented
- [x] Dart services created
- [x] Permissions configured
- [x] UI updated to display real data
- [x] Error handling implemented
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] UI tests added
- [ ] Performance tested on low-end devices
- [ ] Tested on various Android versions (10, 11, 12, 13, 14)
- [ ] User documentation updated
- [ ] Privacy policy updated (storage access disclosure)

## Documentation for Users

### Permission Rationale

The app will show this message when requesting MANAGE_EXTERNAL_STORAGE:

> "StorageMate needs access to your device storage to analyze files and help you free up space. This permission allows the app to:
>
> - Scan your files to identify duplicates and junk
> - Calculate storage usage by category
> - Provide accurate cleanup recommendations
>
> Your files are analyzed locally and never uploaded or shared."

### Manual Permission Grant (Android 11+)

If automatic permission request fails:

1. Open Android Settings
2. Go to Apps → StorageMate
3. Tap Permissions
4. Enable "Files and Media" or "Manage all files"

## Code Examples

### Using Storage Stats in a Widget

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageStats = ref.watch(storageStatsNotifierProvider);

    return storageStats.when(
      data: (deviceInfo) {
        final storage = deviceInfo.external;
        return Text('Used: ${formatBytes(storage.usedBytes)}');
      },
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

### Refreshing Storage Stats

```dart
// In your widget
ref.read(storageStatsNotifierProvider.notifier).refresh();
```

### Accessing Category Breakdown

```dart
final categories = ref.watch(categoryBreakdownProvider);
categories.when(
  data: (breakdown) {
    print('Images: ${formatBytes(breakdown.images)}');
    print('Videos: ${formatBytes(breakdown.videos)}');
  },
  loading: () => /* loading state */,
  error: (e, _) => /* error state */,
);
```
