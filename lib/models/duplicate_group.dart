import 'file_item.dart';

class DuplicateGroup {
  final String groupId;
  final List<FileItem> items;
  final String representativeId;

  const DuplicateGroup({
    required this.groupId,
    required this.items,
    required this.representativeId,
  });
}


