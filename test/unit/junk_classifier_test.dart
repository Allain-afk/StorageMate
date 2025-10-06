import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/core/services/junk_classifier.dart';
import 'package:storagemate/models/file_item.dart';

void main() {
  test('HeuristicJunkClassifier returns empty on stub', () {
    final c = HeuristicJunkClassifier();
    final recs = c.classify(const <FileItem>[]);
    expect(recs, isEmpty);
  });
}


