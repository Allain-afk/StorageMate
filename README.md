# StorageMate

A production-ready Flutter app scaffold that analyzes device storage and recommends safe cleanup actions using explainable heuristics. Target: Android first.

## Requirements
- Flutter 3.x (tested with 3.35.5)
- Dart 3.9.x
- Android SDK / emulator

## Getting Started
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

## Android permissions
- Uses Android 13+ runtime media permissions: `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`
- Fallback for Android 12 and below: `READ_EXTERNAL_STORAGE` (and legacy write for <=28)
- High-privilege `MANAGE_EXTERNAL_STORAGE` is NOT requested. For broader access, guide users to SAF.

## Structure
- `lib/core` utilities and services (scanner, duplicate detection, junk classifier, permissions, cleanup, isolate runner)
- `lib/models` data models (`FileItem`, `DuplicateGroup`, `Recommendation`, `ScanResult`, `CleanupPlan`)
- `lib/repositories` Hive-backed cache (stubs)
- `lib/features` UI modules (dashboard, scan, duplicates, junk, recents, review, settings)
- `lib/widgets` shared UI

## Current status (v1 scaffold)
- Riverpod and go_router wired
- Placeholders for all core screens
- Services stubbed; isolates seam provided
- Lints enabled, unit and golden tests included

## Roadmap
- Implement multi-phase scan engine using isolates
- Duplicate detection (size → quick hash → full hash) with streaming hashing
- Junk heuristics with confidence scoring and explanations
- Rarely-used detection by last accessed/modified
- Review and SAF-compatible delete-to-trash with 7-day undo
- Hive caches for hashes and scan metadata
- Scheduling via WorkManager
- Optional ML seam (perceptual hashing/visual similarity)

## Testing
- Unit tests in `test/unit`
- Golden tests in `test/golden` (baselines under `test/goldens/`)
- Update goldens:
```bash
flutter test --update-goldens
```

## Scripts
Common commands (run at repo root):
```bash
flutter format .
flutter analyze
flutter test
flutter build apk --debug
```
