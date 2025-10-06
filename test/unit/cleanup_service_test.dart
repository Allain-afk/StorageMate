import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/core/services/cleanup_service.dart';
import 'package:storagemate/models/cleanup_plan.dart';

void main() {
  test('CleanupService execute returns true (stub)', () async {
    final svc = CleanupService();
    const plan = CleanupPlan(selections: [], totalBytes: 0);
    final ok = await svc.execute(plan);
    expect(ok, isTrue);
  });
}


