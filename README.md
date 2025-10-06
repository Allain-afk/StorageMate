# StorageMate

A comprehensive Android storage management app built with Flutter that helps users analyze and clean up their device storage.

## Features

### ✨ Real Storage Analysis

- **Accurate Storage Statistics**: Displays actual device storage usage (total, used, free) from Android system APIs
- **Category Breakdown**: Analyzes files by type (Images, Videos, Audio, Documents, APKs, Downloads, Cache, Other)
- **MediaStore Integration**: Uses Android MediaStore API for fast and accurate media file access
- **Duplicate Detection**: Identifies duplicate files using content hashing
- **Junk File Classification**: Automatically identifies potentially unnecessary files
- **Rarely Used Files**: Finds files that haven't been accessed in 90+ days

### 📱 Google Files-Inspired UI

- **Modern Material Design 3**: Clean, intuitive interface following Material You guidelines
- **Smart Navigation**: Proper back button handling and navigation flow
- **Category Views**: Dedicated screens for Duplicates, Junk, and Rarely Used files
- **Real-time Updates**: Automatically refreshes data when available
- **Loading States**: Smooth loading indicators and error handling

### 🔒 Privacy & Permissions

- **Granular Permissions**: Requests only necessary permissions based on Android version
- **Android 11+ Support**: Uses MANAGE_EXTERNAL_STORAGE for comprehensive file access
- **Android 13+ Support**: Supports granular media permissions (Photos, Videos, Audio)
- **Local Processing**: All analysis happens on-device; no data is uploaded or shared

## Screenshots

[Add screenshots here]

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (Android 10+)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/storagemate.git
cd storagemate
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Architecture

### Platform Channel

The app uses a custom platform channel to access Android storage APIs:

- **StatFs**: For storage statistics
- **MediaStore**: For media file access
- **File System APIs**: For comprehensive file scanning

### State Management

- **Riverpod**: For reactive state management
- **Providers**: Separate providers for storage stats, category breakdown, and scan results
- **AsyncNotifiers**: For data that can be refreshed

### Key Services

- **StorageStatsService**: Interface to platform channel for storage data
- **EnhancedFileScannerService**: Efficient file discovery using MediaStore
- **PermissionsService**: Handles storage permissions across Android versions
- **DuplicateDetector**: Identifies duplicate files using SHA-256 hashing
- **JunkClassifier**: Classifies junk files using heuristics

## Permissions

The app requires the following permissions:

### Android 13+ (API 33+)

- `READ_MEDIA_IMAGES`
- `READ_MEDIA_VIDEO`
- `READ_MEDIA_AUDIO`
- `READ_MEDIA_VISUAL_USER_SELECTED`

### Android 11-12 (API 30-32)

- `MANAGE_EXTERNAL_STORAGE` (for comprehensive access)
- `READ_EXTERNAL_STORAGE` (fallback)

### Android 10 and below (API 29-)

- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE` (for API 28 and below)

## Usage

### First Run

1. Launch the app
2. Grant storage permissions when prompted
3. Tap "Smart Clean" to start your first scan
4. Wait for the scan to complete
5. View results in the dashboard

### Viewing Storage Data

- **Dashboard**: Shows overall storage statistics and reclaimable space
- **Categories**: Browse by file type (Images, Videos, etc.)
- **Duplicates**: View and select duplicate files to remove
- **Junk Files**: Review and clean up junk files
- **Rarely Used**: Find files you haven't used in 90+ days

### Refreshing Data

- Tap the refresh icon in the dashboard to update storage statistics
- Re-run a scan to get latest file analysis

## Testing

### Run Unit Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter test integration_test/
```

### Run Widget Tests

```bash
flutter test test/widget_test.dart
```

## Building for Release

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
├── core/
│   ├── providers/          # Riverpod providers
│   ├── services/           # Business logic services
│   └── utils/              # Utility functions
├── features/
│   ├── dashboard/          # Home screen
│   ├── scan/               # Scan functionality
│   ├── results/            # Results overview
│   ├── duplicates/         # Duplicate files
│   ├── junk/               # Junk files
│   ├── recents/            # Rarely used files
│   ├── review/             # Review & confirm
│   └── settings/           # App settings
├── models/                 # Data models
├── widgets/                # Reusable widgets
├── app_shell.dart          # Navigation shell
└── main.dart               # App entry point

android/
└── app/src/main/kotlin/
    └── app/storagemate/storagemate/
        ├── MainActivity.kt
        └── StorageChannel.kt  # Platform channel implementation
```

## Documentation

For detailed implementation documentation, see:

- [STORAGE_IMPLEMENTATION.md](STORAGE_IMPLEMENTATION.md) - Complete storage implementation guide
- [API Documentation](docs/api.md) - Platform channel API reference (TBD)

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Known Issues

1. **Large Storage Scanning**: Devices with 100GB+ of files may take several minutes to scan
2. **Android Version Detection**: Currently assumes Android 13; needs platform channel for actual SDK version
3. **SD Card Support**: Not yet implemented; only internal and primary external storage supported

## Roadmap

- [ ] Background scanning with WorkManager
- [ ] SD Card support
- [ ] Incremental scanning (only changed files)
- [ ] Custom category definitions
- [ ] Cloud storage integration
- [ ] File compression analysis
- [ ] Storage usage predictions
- [ ] Automated cleaning schedules

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Privacy Policy

StorageMate respects your privacy:

- All file analysis happens on your device
- No data is collected or transmitted to external servers
- Storage access is used only for analysis and cleanup
- No ads or tracking

## Support

For issues, questions, or suggestions:

- Open an issue on [GitHub](https://github.com/yourusername/storagemate/issues)
- Email: support@storagemate.app (TBD)

## Acknowledgments

- Inspired by Google Files app
- Built with Flutter and Material Design 3
- Uses Android MediaStore and StatFs APIs
- Community contributions and feedback

---

Made with ❤️ using Flutter
