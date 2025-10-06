import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/core/services/duplicate_detector.dart';
import 'package:storagemate/models/file_item.dart';

void main() {
  test('DuplicateDetector returns empty on empty input (stub)', () async {
    final d = DuplicateDetector();
    final groups = await d.detect(const <FileItem>[]);
    expect(groups, isEmpty);
  });
}


