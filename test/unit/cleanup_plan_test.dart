import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/models/cleanup_plan.dart';

void main() {
  test('CleanupPlan sums selections', () {
    const plan = CleanupPlan(selections: [Selection(id: 'a', isGroup: false)], totalBytes: 500);
    expect(plan.totalBytes, 500);
    expect(plan.selections.first.id, 'a');
  });
}


