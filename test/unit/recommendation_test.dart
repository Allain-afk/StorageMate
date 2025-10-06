import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/models/recommendation.dart';

void main() {
  test('Recommendation fields', () {
    const r = Recommendation(
      id: 'x',
      type: 'junk',
      confidence: 0.9,
      reason: 'APK older than 90 days',
      bytesReclaimable: 1024,
    );
    expect(r.type, 'junk');
    expect(r.confidence, greaterThan(0.0));
    expect(r.bytesReclaimable, 1024);
  });
}


