# StorageMate

Analyze device storage and recommend safe, explainable cleanup actions using on-device heuristics. Android-first, Material 3 UI, Riverpod state, go_router navigation, isolates for heavy I/O.

## Requirements

- Flutter 3.x (tested with 3.35.5)
- Dart 3.9.x
- Android SDK/emulator or physical device

## Run

```bash
flutter pub get
flutter analyze
flutter run
```

## What’s included

- Material 3 UI
  - Dashboard with overview cards and category chips
  - Scan screen with progress/results summary
- Riverpod controllers and go_router routes
- On-device scan engine (iterative traversal + throttling)
- Duplicate grouping (size → quick hash → full hash)
- Junk heuristics (cache/temp/log, old APKs, old Downloads media)
- Isolate runner seam for heavy work

## Permissions (Android)

- Android 13+: requests `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`
- Android 12 and below: requests `READ_EXTERNAL_STORAGE`
- We do not request `MANAGE_EXTERNAL_STORAGE`. For broader access, use SAF/folder picker (planned).

## Known limitations

- Scoped storage blocks `Android/data` and `Android/obb`; the scanner skips these to avoid errors
- Deletion currently stubbed; v1 will move to app-private trash then purge after confirm/undo

## Project structure

- `lib/core`: services (`file_scanner_service.dart`, `duplicate_detector.dart`, `junk_classifier.dart`, `permissions_service.dart`, `cleanup_service.dart`, `isolate_runner.dart`) and utils (`hashing.dart`)
- `lib/models`: `FileItem`, `DuplicateGroup`, `Recommendation`, `ScanResult`, `CleanupPlan`
- `lib/features`: `dashboard`, `scan`, `duplicates`, `junk`, `recents`, `review`, `settings`
- `lib/widgets`: shared UI (`stats_cards.dart`, `section.dart`, `common.dart`)

## Design/UX

- Material 3 color scheme with `colorSchemeSeed`
- Lightweight components only (no heavy UI packages)
- Accessibility: large text/semantics-friendly layout

## Roadmap

- Results tabs (Duplicates, Junk, Rarely used) with review/selection flow
- SAF folder picker; app-private trash and 7‑day undo
- Hive caches (hash index, last scan metadata)
- Weekly scan scheduling via WorkManager
- ML seam (pHash/visual similarity) via on-device models

## Troubleshooting

- If you see “permission denied” on `Android/data`, this is expected under scoped storage; paths are skipped
- Emulator performance: scanning large trees may take time; the traversal is throttled to keep UI responsive
