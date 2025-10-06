import 'package:flutter_test/flutter_test.dart';
import 'package:storagemate/models/duplicate_group.dart';
import 'package:storagemate/models/file_item.dart';

void main() {
  test('DuplicateGroup holds items', () {
    final items = [
      FileItem(
        id: 'a',
        path: '/a',
        name: 'a',
        size: 1,
        lastModified: DateTime(2020),
      ),
      FileItem(
        id: 'b',
        path: '/b',
        name: 'b',
        size: 1,
        lastModified: DateTime(2021),
      ),
    ];
    final g = DuplicateGroup(groupId: 'g1', items: items, representativeId: 'b');
    expect(g.items.length, 2);
    expect(g.representativeId, 'b');
  });
}


