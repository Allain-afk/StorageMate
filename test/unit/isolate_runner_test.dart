import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/core/services/isolate_runner.dart';

void main() {
  test('IsolateRunner run returns computed value (stub)', () async {
    final runner = IsolateRunner();
    final result = await runner.run<int, int>((n) => n * 2, 21);
    expect(result, 42);
  });
}


