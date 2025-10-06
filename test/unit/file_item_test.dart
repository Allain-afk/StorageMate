import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/models/file_item.dart';

void main() {
  test('FileItem constructs with required fields', () {
    final item = FileItem(
      id: '1',
      path: '/tmp/a.txt',
      name: 'a.txt',
      size: 123,
      lastModified: DateTime.fromMillisecondsSinceEpoch(0),
    );
    expect(item.id, '1');
    expect(item.size, 123);
    expect(item.mimeType, isNull);
  });
}


