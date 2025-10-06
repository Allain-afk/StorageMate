import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/core/services/permissions_service.dart';

void main() {
  test('PermissionsService ensureStorageAccess returns true (stub)', () async {
    final svc = PermissionsService();
    final ok = await svc.ensureStorageAccess();
    expect(ok, isTrue);
  });
}


