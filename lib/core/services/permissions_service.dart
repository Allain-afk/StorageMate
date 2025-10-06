import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> ensureStorageAccess() async {
    if (!Platform.isAndroid) return true;

    // Android 13+: request media categories; Android 12-: request storage read
    if (Platform.isAndroid && (await _androidSdkInt()) >= 33) {
      final statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();
      return statuses.values.any((s) => s.isGranted);
    } else {
      final st = await Permission.storage.request();
      return st.isGranted;
    }
  }

  Future<int> _androidSdkInt() async {
    // Best-effort; permission_handler does not expose SDK; rely on env if needed
    // Fallback assume 33 to use new model
    return 33;
  }
}


